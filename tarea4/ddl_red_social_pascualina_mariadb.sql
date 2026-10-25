-- Red social estudiantil pascualina - grupo 6
-- Script DDL de la tarea 4 (versión MariaDB)
-- SGBD: MariaDB 10.11 (también debe correr en 10.6 o superior)
-- Integrantes: Karen Castro, Jorge Mazo, Samuel Hincapié,
--              Paula Morales, Ali Arias
-- Fecha: 2026-10-24
--
-- Notas de la traducción desde PostgreSQL:
-- - generated always as identity -> auto_increment.
-- - timestamptz -> datetime. MariaDB no tiene un tipo con zona horaria;
--   las fechas de interacción se guardan en la hora del servidor
--   (convención recomendada: guardar siempre en UTC desde la aplicación).
-- - jsonb -> json. En MariaDB json es un alias de longtext con validación
--   automática (json_valid). No existe jsonb ni índice GIN. La validación
--   de que sea un objeto { ... } usa json_type en lugar de jsonb_typeof.
-- - default current_date -> default (current_date): MariaDB exige los
--   paréntesis para usar una expresión como valor por defecto en columnas
--   que no son datetime.
-- - comment on table/column -> cláusula comment dentro de cada create table.
-- - drop table ... cascade -> drop table sin cascade (MariaDB lo ignora);
--   el orden de borrado ya respeta las llaves foráneas.
-- - Cada tabla declara engine=InnoDB (necesario para llaves foráneas y
--   check) y juego de caracteres utf8mb4 (tildes y emojis).
-- - La tabla mentor_materia_habilitada se crea antes que sesion_mentoria
--   porque la segunda tiene una FK compuesta hacia la primera.

-- Limpieza por si el script se vuelve a ejecutar.
drop table if exists mensaje;
drop table if exists asistencia_evento;
drop table if exists miembro_grupo;
drop table if exists evento;
drop table if exists grupo;
drop table if exists tipo_grupo;
drop table if exists valoracion_recurso;
drop table if exists recurso_academico;
drop table if exists tipo_recurso;
drop table if exists reaccion;
drop table if exists comentario;
drop table if exists seguidor_estudiante;
drop table if exists publicacion;
drop table if exists tipo_publicacion;
drop table if exists estudiante_habilidad;
drop table if exists estudiante_interes;
drop table if exists habilidad;
drop table if exists interes;
drop table if exists sesion_mentoria;
drop table if exists mentor_materia_habilitada;
drop table if exists perfil_social;
drop table if exists estudiante;
drop table if exists materia_asignatura;
drop table if exists programa_academico;


-- ============================================
-- Módulo 1: usuarios y datos académicos
-- ============================================

-- programa académico (catálogo)
create table programa_academico (
    codigo_programa  int          not null auto_increment,
    nombre_programa  varchar(100) not null,
    nivel            varchar(20)  not null,
    descripcion      varchar(255),

    constraint pk_programa_academico primary key (codigo_programa),
    constraint uq_programa_nombre     unique      (nombre_programa),
    constraint chk_programa_nivel     check (nivel in ('tecnico', 'tecnologico', 'profesional'))
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Catálogo de programas académicos del Pascual.';


-- materia (pertenece a un programa)
create table materia_asignatura (
    codigo_materia   int          not null auto_increment,
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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Materias asociadas a un programa.';


-- estudiante (entidad principal del modelo)
create table estudiante (
    codigo_estudiante     int          not null auto_increment,
    nombre                varchar(50)  not null,
    apellido              varchar(50)  not null,
    correo_institucional  varchar(100) not null,
    fecha_nacimiento      date         not null,
    semestre              int          not null,
    fecha_registro        date         not null default (current_date),
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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Datos institucionales del estudiante.';


-- perfil social (1:1 con estudiante)
create table perfil_social (
    codigo_perfil         int          not null auto_increment,
    descripcion_personal  varchar(255),
    area_estudio          varchar(100) not null,
    fotografia            varchar(255),
    biografia             varchar(500),
    tipo_mentoria         varchar(50),
    codigo_estudiante     int          not null comment 'FK+UNIQUE: garantiza el 1:1 con estudiante (RI-04).',

    constraint pk_perfil_social     primary key (codigo_perfil),
    -- unique garantiza el 1:1 (ri-04)
    constraint uq_perfil_estudiante unique      (codigo_estudiante),

    -- cascade: un perfil no existe sin el estudiante
    constraint fk_perfil_estudiante
        foreign key (codigo_estudiante)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Datos sociales del estudiante (1:1 con estudiante).';


-- ============================================
-- Módulo 2: mentorías
-- ============================================

-- habilitación de un estudiante como mentor de una materia (n:m)
create table mentor_materia_habilitada (
    codigo_estudiante   int          not null,
    codigo_materia      int          not null,
    fecha_habilitacion  date         not null default (current_date),
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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Habilitación de un estudiante como mentor de una materia (N:M).';


-- sesión de mentoría
-- la fk compuesta (mentor, materia) garantiza que el mentor esté
-- habilitado en esa materia antes de crear la sesión.
create table sesion_mentoria (
    codigo_sesion    int          not null auto_increment,
    fecha_sesion     date         not null,
    hora_sesion      time         not null,
    tema             varchar(150) not null,
    estado           varchar(20)  not null default 'programada',
    codigo_mentor    int          not null comment 'Parte de la FK compuesta (mentor, materia) hacia mentor_materia_habilitada.',
    codigo_aprendiz  int          not null,
    codigo_materia   int          not null comment 'Parte de la FK compuesta: garantiza que el mentor esté habilitado en esa materia.',

    constraint pk_sesion_mentoria   primary key (codigo_sesion),
    constraint chk_sesion_estado    check (estado in ('programada', 'realizada', 'cancelada')),
    constraint chk_sesion_distintos check (codigo_mentor <> codigo_aprendiz),

    -- ri-07: la sesión debe tener un mentor habilitado en la materia
    constraint fk_sesion_mentor_habilitado
        foreign key (codigo_mentor, codigo_materia)
        references mentor_materia_habilitada (codigo_estudiante, codigo_materia)
        on delete restrict
        on update restrict,

    -- ri-07: la sesión debe tener un aprendiz
    constraint fk_sesion_aprendiz
        foreign key (codigo_aprendiz)
        references estudiante (codigo_estudiante)
        on delete restrict
        on update restrict
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Citas de mentoría entre mentor y aprendiz.';


-- ============================================
-- Módulo 3: perfiles y preferencias
-- ============================================

create table interes (
    codigo_interes  int         not null auto_increment,
    nombre_interes  varchar(80) not null,
    descripcion     varchar(255),

    constraint pk_interes        primary key (codigo_interes),
    constraint uq_interes_nombre unique      (nombre_interes)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Catálogo de intereses.';


create table habilidad (
    codigo_habilidad  int         not null auto_increment,
    nombre_habilidad  varchar(80) not null,
    descripcion       varchar(255),

    constraint pk_habilidad        primary key (codigo_habilidad),
    constraint uq_habilidad_nombre unique      (nombre_habilidad)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Catálogo de habilidades.';


-- n:m estudiante - interés
create table estudiante_interes (
    codigo_estudiante  int  not null,
    codigo_interes     int  not null,
    fecha_asociacion   date default (current_date),

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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='N:M entre estudiante e interés.';


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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='N:M entre estudiante y habilidad.';


-- ============================================
-- Módulo 4: publicaciones e interacciones
-- ============================================

create table tipo_publicacion (
    codigo_tipo_publicacion int         not null auto_increment,
    nombre_tipo             varchar(50) not null,
    descripcion             varchar(255),

    constraint pk_tipo_publicacion primary key (codigo_tipo_publicacion),
    constraint uq_tipo_publicacion unique      (nombre_tipo)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Catálogo de tipos de publicación (pregunta, recurso, noticia, meme).';


-- publicación (muro de actualizaciones)
create table publicacion (
    codigo_publicacion      int          not null auto_increment,
    contenido               varchar(500) not null,
    fecha_publicacion       datetime     not null default current_timestamp,
    archivo_adjunto         varchar(255),
    metadatos_dispositivo   json         comment 'JSON con la telemetría del dispositivo que publica (navegador, sistema operativo, tipo de conexión, resolución, huella, versión de la app, latencia en ms). Opcional.',
    codigo_estudiante       int          not null comment 'FK: autor de la publicación (RI-01).',
    codigo_tipo_publicacion int          not null,

    constraint pk_publicacion primary key (codigo_publicacion),

    -- el JSON debe ser un objeto { ... }, no un arreglo ni un valor suelto
    constraint chk_publicacion_metadatos
        check (metadatos_dispositivo is null
               or json_type(metadatos_dispositivo) = 'OBJECT'),

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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Muro de actualizaciones de la red social.';


-- seguidor (relación reflexiva n:m)
create table seguidor_estudiante (
    codigo_seguidor    int  not null comment 'FK: estudiante que sigue.',
    codigo_seguido     int  not null comment 'FK: estudiante seguido.',
    fecha_seguimiento  date not null default (current_date),

    constraint pk_seguidor_estudiante primary key (codigo_seguidor, codigo_seguido),
    constraint chk_seguidor_distintos check (codigo_seguidor <> codigo_seguido),

    constraint fk_seguidor_seguidor
        foreign key (codigo_seguidor)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update restrict,

    constraint fk_seguidor_seguido
        foreign key (codigo_seguido)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update restrict
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='N:M reflexiva entre estudiantes (sigue).';


-- comentario (entidad transaccional, pk propia)
create table comentario (
    codigo_comentario  int          not null auto_increment comment 'PK propia: un estudiante puede comentar varias veces la misma publicación.',
    contenido          varchar(500) not null,
    fecha_comentario   datetime     not null default current_timestamp,
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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Comentarios de estudiantes sobre publicaciones.';


-- reacción (n:m estudiante - publicación)
create table reaccion (
    codigo_estudiante   int         not null,
    codigo_publicacion  int         not null,
    tipo_reaccion       varchar(20) not null,
    fecha_reaccion      datetime    not null default current_timestamp,

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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Reacciones de estudiantes a publicaciones (N:M).';


-- ============================================
-- Módulo 5: recursos académicos
-- ============================================

create table tipo_recurso (
    codigo_tipo_recurso int         not null auto_increment,
    nombre_tipo         varchar(50) not null,
    descripcion         varchar(255),

    constraint pk_tipo_recurso primary key (codigo_tipo_recurso),
    constraint uq_tipo_recurso unique      (nombre_tipo)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Catálogo de tipos de recurso (PDF, enlace, código, video, documento).';


-- recurso académico compartido por un estudiante
create table recurso_academico (
    codigo_recurso      int          not null auto_increment,
    titulo              varchar(150) not null,
    descripcion         varchar(500),
    url_archivo         varchar(255) not null,
    fecha_subida        datetime     not null default current_timestamp,
    codigo_estudiante   int          not null,
    codigo_materia      int          not null comment 'FK: materia del recurso (RI-08).',
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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Material académico compartido por un estudiante.';


-- valoración (n:m estudiante - recurso)
create table valoracion_recurso (
    codigo_estudiante  int         not null,
    codigo_recurso     int         not null,
    puntuacion         int         not null,
    comentario         varchar(255),
    fecha_valoracion   datetime    not null default current_timestamp,

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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='N:M entre estudiante y recurso (valoración).';


-- ============================================
-- Módulo 6: comunidades, grupos y eventos
-- ============================================

create table tipo_grupo (
    codigo_tipo_grupo int         not null auto_increment,
    nombre_tipo       varchar(50) not null,
    descripcion       varchar(255),

    constraint pk_tipo_grupo primary key (codigo_tipo_grupo),
    constraint uq_tipo_grupo unique      (nombre_tipo)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Catálogo de tipos de grupo (estudio, hackatón, club).';


-- grupo
create table grupo (
    codigo_grupo              int          not null auto_increment,
    nombre_grupo              varchar(100) not null,
    descripcion               varchar(500),
    fecha_creacion            date         not null default (current_date),
    codigo_estudiante_creador int          not null comment 'FK: creador del grupo (RI-02).',
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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Espacios comunitarios creados por estudiantes.';


-- evento
create table evento (
    codigo_evento             int          not null auto_increment,
    nombre_evento             varchar(100) not null,
    fecha_evento              date         not null,
    hora_evento               time         not null,
    lugar                     varchar(150) not null,
    estado                    varchar(20)  not null default 'programado',
    descripcion               varchar(500),
    codigo_estudiante_creador int          not null comment 'FK: creador del evento (RI-03).',

    constraint pk_evento         primary key (codigo_evento),
    constraint chk_evento_estado check (estado in ('programado', 'realizado', 'cancelado')),

    -- ri-03: todo evento tiene creador
    constraint fk_evento_creador
        foreign key (codigo_estudiante_creador)
        references estudiante (codigo_estudiante)
        on delete restrict
        on update cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Actividades programadas (talleres, reuniones, actividades sociales).';


-- miembro de grupo (n:m)
create table miembro_grupo (
    codigo_estudiante  int         not null,
    codigo_grupo       int         not null,
    fecha_union        date        not null default (current_date),
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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='N:M entre estudiante y grupo (unirse).';


-- asistencia a evento (n:m)
create table asistencia_evento (
    codigo_estudiante  int         not null,
    codigo_evento      int         not null,
    fecha_inscripcion  date        not null default (current_date),
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
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='N:M entre estudiante y evento (asistencia).';


-- ============================================
-- Módulo 7: comunicación interna
-- ============================================

-- mensaje directo (relación reflexiva n:m)
-- pk propia porque un mismo par de estudiantes se escribe muchas veces.
create table mensaje (
    codigo_mensaje  int          not null auto_increment comment 'PK propia: un mismo par emisor-receptor puede intercambiar muchos mensajes.',
    contenido       varchar(500) not null,
    fecha_envio     datetime     not null default current_timestamp,
    leido           boolean      not null default false,
    codigo_emisor   int          not null comment 'FK: estudiante emisor (RI-09).',
    codigo_receptor int          not null comment 'FK: estudiante receptor (RI-09).',

    constraint pk_mensaje            primary key (codigo_mensaje),
    constraint chk_mensaje_distintos check (codigo_emisor <> codigo_receptor),

    constraint fk_mensaje_emisor
        foreign key (codigo_emisor)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update restrict,

    constraint fk_mensaje_receptor
        foreign key (codigo_receptor)
        references estudiante (codigo_estudiante)
        on delete cascade
        on update restrict
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci
  comment='Mensajería directa entre estudiantes (N:M reflexiva).';


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
-- MariaDB no tiene índice GIN para json. Si hace falta buscar por un campo
-- del JSON, se indexa una columna virtual, por ejemplo (la clave
-- 'sistema_operativo' es solo un ejemplo):
--   alter table publicacion
--     add column so_dispositivo varchar(50)
--         as (json_value(metadatos_dispositivo, '$.sistema_operativo')) virtual,
--     add index idx_publicacion_so (so_dispositivo);
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
