-- Red social estudiantil pascualina - grupo 6
-- Script DDL de la tarea 3 (implementación física del modelo lógico)
-- SGBD: PostgreSQL 16
-- Integrantes: Karen Castro, Jorge Mazo, Samuel Hincapié,
--              Paula Morales, Ali Arias
-- Fecha: 2026-10-18
--
-- Notas:
-- - Los identificadores se guardan en minúsculas porque PostgreSQL
--   normaliza los nombres no citados. El informe y el diagrama usan
--   mayúsculas solo por legibilidad.
-- - Se usa timestamptz en las fechas de interacción (publicaciones,
--   comentarios, mensajes, etc.) porque un muro social necesita orden
--   cronológico con zona horaria.
-- - La tabla mentor_materia_habilitada se crea antes que sesion_mentoria
--   porque la segunda tiene una FK compuesta hacia la primera.

-- Limpieza por si el script se vuelve a ejecutar.
drop table if exists mensaje cascade;
drop table if exists asistencia_evento cascade;
drop table if exists miembro_grupo cascade;
drop table if exists evento cascade;
drop table if exists grupo cascade;
drop table if exists tipo_grupo cascade;
drop table if exists valoracion_recurso cascade;
drop table if exists recurso_academico cascade;
drop table if exists tipo_recurso cascade;
drop table if exists reaccion cascade;
drop table if exists comentario cascade;
drop table if exists seguidor_estudiante cascade;
drop table if exists publicacion cascade;
drop table if exists tipo_publicacion cascade;
drop table if exists estudiante_habilidad cascade;
drop table if exists estudiante_interes cascade;
drop table if exists habilidad cascade;
drop table if exists interes cascade;
drop table if exists sesion_mentoria cascade;
drop table if exists mentor_materia_habilitada cascade;
drop table if exists perfil_social cascade;
drop table if exists estudiante cascade;
drop table if exists materia_asignatura cascade;
drop table if exists programa_academico cascade;


-- ============================================
-- Módulo 1: usuarios y datos académicos
-- ============================================

-- programa académico (catálogo)
create table programa_academico (
    codigo_programa  int          generated always as identity,
    nombre_programa  varchar(100) not null,
    nivel            varchar(20)  not null,
    descripcion      varchar(255),

    constraint pk_programa_academico primary key (codigo_programa),
    constraint uq_programa_nombre     unique      (nombre_programa),
    constraint chk_programa_nivel     check (nivel in ('tecnico', 'tecnologico', 'profesional'))
);


-- materia (pertenece a un programa)
create table materia_asignatura (
    codigo_materia   int          generated always as identity,
    nombre_materia   varchar(100) not null,
    creditos         int          not null,
    semestre         int          not null,
    codigo_programa  int          not null,

    constraint pk_materia_asignatura primary key (codigo_materia),
    constraint uq_materia_nombre     unique      (nombre_materia),
    constraint chk_materia_creditos  check (creditos > 0),
    constraint chk_materia_semestre  check (semestre between 1 and 10),

    -- restrict: no se puede borrar un programa con materias
    constraint fk_materia_programa
        foreign key (codigo_programa)
        references programa_academico (codigo_programa)
        on delete restrict
        on update cascade
);


-- estudiante (entidad principal del modelo)
create table estudiante (
    codigo_estudiante     int          generated always as identity,
    nombre                varchar(50)  not null,
    apellido              varchar(50)  not null,
    correo_institucional  varchar(100) not null,
    fecha_nacimiento      date         not null,
    semestre              int          not null,
    fecha_registro        date         not null default current_date,
    codigo_programa       int          not null,

    constraint pk_estudiante           primary key (codigo_estudiante),
    constraint uq_estudiante_correo    unique      (correo_institucional),
    constraint chk_estudiante_semestre check (semestre between 1 and 10),

    -- ri-05: todo estudiante pertenece a un solo programa
    constraint fk_estudiante_programa
        foreign key (codigo_programa)
        references programa_academico (codigo_programa)
        on delete restrict
        on update cascade
);


-- perfil social (1:1 con estudiante)
create table perfil_social (
    codigo_perfil         int          generated always as identity,
    descripcion_personal  varchar(255),
    area_estudio          varchar(100) not null,
    fotografia            varchar(255),
    biografia             varchar(500),
    tipo_mentoria         varchar(50),
    codigo_estudiante     int          not null,

    constraint pk_perfil_social     primary key (codigo_perfil),
    -- unique garantiza el 1:1 (ri-04)
    constraint uq_perfil_estudiante unique      (codigo_estudiante),

    -- cascade: un perfil no existe sin el estudiante
    constraint fk_perfil_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade
);


-- ============================================
-- Módulo 2: mentorías
-- ============================================

-- habilitación de un estudiante como mentor de una materia (n:m)
create table mentor_materia_habilitada (
    codigo_estudiante   int          not null,
    codigo_materia      int          not null,
    fecha_habilitacion  date         not null default current_date,
    certificado         varchar(255),

    constraint pk_mentor_materia primary key (codigo_estudiante, codigo_materia),

    constraint fk_mentor_hab_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_mentor_hab_materia
        foreign key (codigo_materia)
        references materia_asignatura (codigo_materia)
        on delete cascade
        on update cascade
);


-- sesión de mentoría
-- la fk compuesta (mentor, materia) garantiza que el mentor esté
-- habilitado en esa materia antes de crear la sesión.
create table sesion_mentoria (
    codigo_sesion    int          generated always as identity,
    fecha_sesion     date         not null,
    hora_sesion      time         not null,
    tema             varchar(150) not null,
    estado           varchar(20)  not null default 'programada',
    codigo_mentor    int          not null,
    codigo_aprendiz  int          not null,
    codigo_materia   int          not null,

    constraint pk_sesion_mentoria   primary key (codigo_sesion),
    constraint chk_sesion_estado    check (estado in ('programada', 'realizada', 'cancelada')),
    constraint chk_sesion_distintos check (codigo_mentor <> codigo_aprendiz),

    -- ri-07: la sesión debe tener un mentor habilitado en la materia
    constraint fk_sesion_mentor_habilitado
        foreign key (codigo_mentor, codigo_materia)
        references mentor_materia_habilitada (codigo_estudiante, codigo_materia)
        on delete restrict
        on update cascade,

    -- ri-07: la sesión debe tener un aprendiz
    constraint fk_sesion_aprendiz
        foreign key (codigo_aprendiz)
        references estudiante (codigo_estudiante)
        on delete restrict
        on update cascade
);


-- ============================================
-- Módulo 3: perfiles y preferencias
-- ============================================

create table interes (
    codigo_interes  int         generated always as identity,
    nombre_interes  varchar(80) not null,
    descripcion     varchar(255),

    constraint pk_interes        primary key (codigo_interes),
    constraint uq_interes_nombre unique      (nombre_interes)
);


create table habilidad (
    codigo_habilidad  int         generated always as identity,
    nombre_habilidad  varchar(80) not null,
    descripcion       varchar(255),

    constraint pk_habilidad        primary key (codigo_habilidad),
    constraint uq_habilidad_nombre unique      (nombre_habilidad)
);


-- n:m estudiante - interés
create table estudiante_interes (
    codigo_estudiante  int  not null,
    codigo_interes     int  not null,
    fecha_asociacion   date default current_date,

    constraint pk_estudiante_interes primary key (codigo_estudiante, codigo_interes),

    constraint fk_est_interes_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_est_interes_interes
        foreign key (codigo_interes)
        references interes (codigo_interes)
        on delete cascade
        on update cascade
);


-- n:m estudiante - habilidad
create table estudiante_habilidad (
    codigo_estudiante  int         not null,
    codigo_habilidad   int         not null,
    nivel              varchar(20),

    constraint pk_estudiante_habilidad primary key (codigo_estudiante, codigo_habilidad),
    constraint chk_est_hab_nivel       check (nivel in ('basico', 'medio', 'avanzado')),

    constraint fk_est_hab_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_est_hab_habilidad
        foreign key (codigo_habilidad)
        references habilidad (codigo_habilidad)
        on delete cascade
        on update cascade
);


-- ============================================
-- Módulo 4: publicaciones e interacciones
-- ============================================

create table tipo_publicacion (
    codigo_tipo_publicacion int         generated always as identity,
    nombre_tipo             varchar(50) not null,
    descripcion             varchar(255),

    constraint pk_tipo_publicacion primary key (codigo_tipo_publicacion),
    constraint uq_tipo_publicacion unique      (nombre_tipo)
);


-- publicación (muro de actualizaciones)
create table publicacion (
    codigo_publicacion      int          generated always as identity,
    contenido               varchar(500) not null,
    fecha_publicacion       timestamptz  not null default current_timestamp,
    archivo_adjunto         varchar(255),
    codigo_estudiante       int          not null,
    codigo_tipo_publicacion int          not null,

    constraint pk_publicacion primary key (codigo_publicacion),

    -- ri-01: toda publicación tiene autor
    constraint fk_publicacion_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_publicacion_tipo
        foreign key (codigo_tipo_publicacion)
        references tipo_publicacion (codigo_tipo_publicacion)
        on delete restrict
        on update cascade
);


-- seguidor (relación reflexiva n:m)
create table seguidor_estudiante (
    codigo_seguidor    int  not null,
    codigo_seguido     int  not null,
    fecha_seguimiento  date not null default current_date,

    constraint pk_seguidor_estudiante primary key (codigo_seguidor, codigo_seguido),
    constraint chk_seguidor_distintos check (codigo_seguidor <> codigo_seguido),

    constraint fk_seguidor_seguidor
        foreign key (codigo_seguidor)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_seguidor_seguido
        foreign key (codigo_seguido)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade
);


-- comentario (entidad transaccional, pk propia)
create table comentario (
    codigo_comentario  int          generated always as identity,
    contenido          varchar(500) not null,
    fecha_comentario   timestamptz  not null default current_timestamp,
    codigo_estudiante  int          not null,
    codigo_publicacion int          not null,

    constraint pk_comentario primary key (codigo_comentario),

    constraint fk_comentario_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_comentario_publicacion
        foreign key (codigo_publicacion)
        references publicacion (codigo_publicacion)
        on delete cascade
        on update cascade
);


-- reacción (n:m estudiante - publicación)
create table reaccion (
    codigo_estudiante   int         not null,
    codigo_publicacion  int         not null,
    tipo_reaccion       varchar(20) not null,
    fecha_reaccion      timestamptz not null default current_timestamp,

    constraint pk_reaccion primary key (codigo_estudiante, codigo_publicacion),
    constraint chk_reaccion_tipo
        check (tipo_reaccion in ('me gusta', 'me encanta', 'me divierte', 'me asombra')),

    constraint fk_reaccion_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_reaccion_publicacion
        foreign key (codigo_publicacion)
        references publicacion (codigo_publicacion)
        on delete cascade
        on update cascade
);


-- ============================================
-- Módulo 5: recursos académicos
-- ============================================

create table tipo_recurso (
    codigo_tipo_recurso int         generated always as identity,
    nombre_tipo         varchar(50) not null,
    descripcion         varchar(255),

    constraint pk_tipo_recurso primary key (codigo_tipo_recurso),
    constraint uq_tipo_recurso unique      (nombre_tipo)
);


-- recurso académico compartido por un estudiante
create table recurso_academico (
    codigo_recurso      int          generated always as identity,
    titulo              varchar(150) not null,
    descripcion         varchar(500),
    url_archivo         varchar(255) not null,
    fecha_subida        timestamptz  not null default current_timestamp,
    codigo_estudiante   int          not null,
    codigo_materia      int          not null,
    codigo_tipo_recurso int          not null,

    constraint pk_recurso_academico primary key (codigo_recurso),

    -- ri-08: recurso tiene autor
    constraint fk_recurso_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    -- ri-08: recurso tiene materia
    constraint fk_recurso_materia
        foreign key (codigo_materia)
        references materia_asignatura (codigo_materia)
        on delete restrict
        on update cascade,

    constraint fk_recurso_tipo
        foreign key (codigo_tipo_recurso)
        references tipo_recurso (codigo_tipo_recurso)
        on delete restrict
        on update cascade
);


-- valoración (n:m estudiante - recurso)
create table valoracion_recurso (
    codigo_estudiante  int         not null,
    codigo_recurso     int         not null,
    puntuacion         int         not null,
    comentario         varchar(255),
    fecha_valoracion   timestamptz not null default current_timestamp,

    constraint pk_valoracion_recurso primary key (codigo_estudiante, codigo_recurso),
    constraint chk_valoracion_rango  check (puntuacion between 1 and 5),

    constraint fk_valoracion_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_valoracion_recurso
        foreign key (codigo_recurso)
        references recurso_academico (codigo_recurso)
        on delete cascade
        on update cascade
);


-- ============================================
-- Módulo 6: comunidades, grupos y eventos
-- ============================================

create table tipo_grupo (
    codigo_tipo_grupo int         generated always as identity,
    nombre_tipo       varchar(50) not null,
    descripcion       varchar(255),

    constraint pk_tipo_grupo primary key (codigo_tipo_grupo),
    constraint uq_tipo_grupo unique      (nombre_tipo)
);


-- grupo
create table grupo (
    codigo_grupo              int          generated always as identity,
    nombre_grupo              varchar(100) not null,
    descripcion               varchar(500),
    fecha_creacion            date         not null default current_date,
    codigo_estudiante_creador int          not null,
    codigo_tipo_grupo         int          not null,

    constraint pk_grupo        primary key (codigo_grupo),
    constraint uq_grupo_nombre unique      (nombre_grupo),

    -- ri-02: todo grupo tiene creador; restrict para no dejarlo huérfano
    constraint fk_grupo_creador
        foreign key (codigo_estudiante_creador)
        references estudiante (codigo_estudiante)
        on delete restrict
        on update cascade,

    constraint fk_grupo_tipo
        foreign key (codigo_tipo_grupo)
        references tipo_grupo (codigo_tipo_grupo)
        on delete restrict
        on update cascade
);


-- evento
create table evento (
    codigo_evento             int          generated always as identity,
    nombre_evento             varchar(100) not null,
    fecha_evento              date         not null,
    hora_evento               time         not null,
    lugar                     varchar(150) not null,
    estado                    varchar(20)  not null default 'programado',
    descripcion               varchar(500),
    codigo_estudiante_creador int          not null,

    constraint pk_evento         primary key (codigo_evento),
    constraint chk_evento_estado check (estado in ('programado', 'realizado', 'cancelado')),

    -- ri-03: todo evento tiene creador
    constraint fk_evento_creador
        foreign key (codigo_estudiante_creador)
        references estudiante (codigo_estudiante)
        on delete restrict
        on update cascade
);


-- miembro de grupo (n:m)
create table miembro_grupo (
    codigo_estudiante  int         not null,
    codigo_grupo       int         not null,
    fecha_union        date        not null default current_date,
    rol                varchar(20) not null default 'miembro',

    constraint pk_miembro_grupo primary key (codigo_estudiante, codigo_grupo),
    constraint chk_miembro_rol  check (rol in ('miembro', 'moderador')),

    constraint fk_miembro_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_miembro_grupo
        foreign key (codigo_grupo)
        references grupo (codigo_grupo)
        on delete cascade
        on update cascade
);


-- asistencia a evento (n:m)
create table asistencia_evento (
    codigo_estudiante  int         not null,
    codigo_evento      int         not null,
    fecha_inscripcion  date        not null default current_date,
    estado_asistencia  varchar(20) not null default 'inscrito',

    constraint pk_asistencia_evento  primary key (codigo_estudiante, codigo_evento),
    constraint chk_asistencia_estado check (estado_asistencia in ('inscrito', 'asistio', 'no asistio')),

    constraint fk_asistencia_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_asistencia_evento
        foreign key (codigo_evento)
        references evento (codigo_evento)
        on delete cascade
        on update cascade
);


-- ============================================
-- Módulo 7: comunicación interna
-- ============================================

-- mensaje directo (relación reflexiva n:m)
-- pk propia porque un mismo par de estudiantes se escribe muchas veces.
create table mensaje (
    codigo_mensaje  int          generated always as identity,
    contenido       varchar(500) not null,
    fecha_envio     timestamptz  not null default current_timestamp,
    leido           boolean      not null default false,
    codigo_emisor   int          not null,
    codigo_receptor int          not null,

    constraint pk_mensaje            primary key (codigo_mensaje),
    constraint chk_mensaje_distintos check (codigo_emisor <> codigo_receptor),

    constraint fk_mensaje_emisor
        foreign key (codigo_emisor)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade,

    constraint fk_mensaje_receptor
        foreign key (codigo_receptor)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade
);


-- ============================================
-- Comentarios de tablas y columnas clave
-- ============================================

comment on table programa_academico is 'Catálogo de programas académicos del Pascual.';
comment on table materia_asignatura  is 'Materias asociadas a un programa.';
comment on table estudiante          is 'Datos institucionales del estudiante.';
comment on table perfil_social       is 'Datos sociales del estudiante (1:1 con estudiante).';
comment on table mentor_materia_habilitada is 'Habilitación de un estudiante como mentor de una materia (N:M).';
comment on table sesion_mentoria     is 'Citas de mentoría entre mentor y aprendiz.';
comment on table interes             is 'Catálogo de intereses.';
comment on table habilidad           is 'Catálogo de habilidades.';
comment on table estudiante_interes  is 'N:M entre estudiante e interés.';
comment on table estudiante_habilidad is 'N:M entre estudiante y habilidad.';
comment on table tipo_publicacion    is 'Catálogo de tipos de publicación (pregunta, recurso, noticia, meme).';
comment on table publicacion         is 'Muro de actualizaciones de la red social.';
comment on table seguidor_estudiante is 'N:M reflexiva entre estudiantes (sigue).';
comment on table comentario          is 'Comentarios de estudiantes sobre publicaciones.';
comment on table reaccion            is 'Reacciones de estudiantes a publicaciones (N:M).';
comment on table tipo_recurso        is 'Catálogo de tipos de recurso (PDF, enlace, código, video, documento).';
comment on table recurso_academico   is 'Material académico compartido por un estudiante.';
comment on table valoracion_recurso  is 'N:M entre estudiante y recurso (valoración).';
comment on table tipo_grupo          is 'Catálogo de tipos de grupo (estudio, hackatón, club).';
comment on table grupo               is 'Espacios comunitarios creados por estudiantes.';
comment on table evento              is 'Actividades programadas (talleres, reuniones, actividades sociales).';
comment on table miembro_grupo       is 'N:M entre estudiante y grupo (unirse).';
comment on table asistencia_evento   is 'N:M entre estudiante y evento (asistencia).';
comment on table mensaje             is 'Mensajería directa entre estudiantes (N:M reflexiva).';

-- Columnas con significado especial
comment on column sesion_mentoria.codigo_mentor  is 'Parte de la FK compuesta (mentor, materia) hacia mentor_materia_habilitada.';
comment on column sesion_mentoria.codigo_materia is 'Parte de la FK compuesta: garantiza que el mentor esté habilitado en esa materia.';
comment on column comentario.codigo_comentario   is 'PK propia: un estudiante puede comentar varias veces la misma publicación.';
comment on column mensaje.codigo_mensaje         is 'PK propia: un mismo par emisor-receptor puede intercambiar muchos mensajes.';
comment on column seguidor_estudiante.codigo_seguidor is 'FK: estudiante que sigue.';
comment on column seguidor_estudiante.codigo_seguido  is 'FK: estudiante seguido.';
comment on column mensaje.codigo_emisor          is 'FK: estudiante emisor (RI-09).';
comment on column mensaje.codigo_receptor        is 'FK: estudiante receptor (RI-09).';
comment on column publicacion.codigo_estudiante  is 'FK: autor de la publicación (RI-01).';
comment on column grupo.codigo_estudiante_creador is 'FK: creador del grupo (RI-02).';
comment on column evento.codigo_estudiante_creador is 'FK: creador del evento (RI-03).';
comment on column recurso_academico.codigo_materia is 'FK: materia del recurso (RI-08).';
comment on column perfil_social.codigo_estudiante is 'FK+UNIQUE: garantiza el 1:1 con estudiante (RI-04).';


-- ============================================
-- Índices en fk (no se repiten los de unique)
-- ============================================

create index idx_materia_programa       on materia_asignatura (codigo_programa);
create index idx_estudiante_programa    on estudiante (codigo_programa);
create index idx_sesion_aprendiz        on sesion_mentoria (codigo_aprendiz);
create index idx_sesion_mentor_materia  on sesion_mentoria (codigo_mentor, codigo_materia);
create index idx_mentor_hab_materia     on mentor_materia_habilitada (codigo_materia);
create index idx_est_interes_interes    on estudiante_interes (codigo_interes);
create index idx_est_hab_habilidad      on estudiante_habilidad (codigo_habilidad);
create index idx_publicacion_estudiante on publicacion (codigo_estudiante);
create index idx_publicacion_tipo       on publicacion (codigo_tipo_publicacion);
create index idx_seguidor_seguido       on seguidor_estudiante (codigo_seguido);
create index idx_comentario_estudiante  on comentario (codigo_estudiante);
create index idx_comentario_publicacion on comentario (codigo_publicacion);
create index idx_reaccion_publicacion   on reaccion (codigo_publicacion);
create index idx_recurso_estudiante     on recurso_academico (codigo_estudiante);
create index idx_recurso_materia        on recurso_academico (codigo_materia);
create index idx_recurso_tipo           on recurso_academico (codigo_tipo_recurso);
create index idx_valoracion_recurso     on valoracion_recurso (codigo_recurso);
create index idx_grupo_creador          on grupo (codigo_estudiante_creador);
create index idx_grupo_tipo             on grupo (codigo_tipo_grupo);
create index idx_evento_creador         on evento (codigo_estudiante_creador);
create index idx_miembro_grupo          on miembro_grupo (codigo_grupo);
create index idx_asistencia_evento      on asistencia_evento (codigo_evento);
create index idx_mensaje_emisor         on mensaje (codigo_emisor);
create index idx_mensaje_receptor       on mensaje (codigo_receptor);

--