-- =====================================================================
-- DATOS DE PRUEBA PARA LA RED SOCIAL ESTUDIANTIL PASCUALINA
-- Grupo 6 - Tarea 5
-- Ejecutar después del DDL de la Tarea 4.
-- =====================================================================

-- ============================================
-- 1. programa_academico
-- ============================================
INSERT INTO programa_academico (codigo_programa, nombre_programa, nivel, descripcion) OVERRIDING SYSTEM VALUE VALUES
(1, 'Ingeniería de Sistemas', 'profesional', 'Programa de ingeniería enfocado en software y sistemas'),
(2, 'Ingeniería Industrial', 'profesional', 'Programa de ingeniería enfocado en procesos y producción'),
(3, 'Tecnología en Desarrollo de Software', 'tecnologico', 'Tecnología enfocada en desarrollo de aplicaciones');

-- ============================================
-- 2. materia_asignatura
-- ============================================
INSERT INTO materia_asignatura (codigo_materia, nombre_materia, creditos, semestre, codigo_programa) OVERRIDING SYSTEM VALUE VALUES
(1, 'Programación I', 4, 1, 1),
(2, 'Bases de Datos I', 4, 4, 1),
(3, 'Estructuras de Datos', 4, 3, 1),
(4, 'Cálculo I', 4, 1, 2),
(5, 'Gestión de Proyectos', 3, 5, 2),
(6, 'Desarrollo Web', 4, 2, 3);

-- ============================================
-- 3. estudiante
-- ============================================
INSERT INTO estudiante (codigo_estudiante, nombre, apellido, correo_institucional, fecha_nacimiento, semestre, fecha_registro, codigo_programa) OVERRIDING SYSTEM VALUE VALUES
(1, 'Juan', 'Pérez', 'juan.perez@upascual.edu.co', '2000-05-15', 5, '2026-01-20', 1),
(2, 'María', 'Gómez', 'maria.gomez@upascual.edu.co', '2001-08-22', 3, '2026-01-20', 1),
(3, 'Carlos', 'López', 'carlos.lopez@upascual.edu.co', '1999-12-10', 6, '2026-01-20', 2),
(4, 'Ana', 'Rodríguez', 'ana.rodriguez@upascual.edu.co', '2002-03-05', 2, '2026-01-20', 3),
(5, 'Luis', 'Martínez', 'luis.martinez@upascual.edu.co', '1998-07-30', 8, '2026-01-20', 1),
(6, 'Laura', 'Sánchez', 'laura.sanchez@upascual.edu.co', '2000-11-12', 4, '2026-01-20', 2),
(7, 'Pedro', 'Ramírez', 'pedro.ramirez@upascual.edu.co', '2003-01-25', 1, '2026-01-20', 1),
(8, 'Sofía', 'Torres', 'sofia.torres@upascual.edu.co', '2001-09-18', 3, '2026-01-20', 3),
(9, 'Diego', 'Herrera', 'diego.herrera@upascual.edu.co', '1999-04-02', 7, '2026-01-20', 1),
(10, 'Valeria', 'Castro', 'valeria.castro@upascual.edu.co', '2002-06-14', 2, '2026-01-20', 2),
(11, 'Andrés', 'Jiménez', 'andres.jimenez@upascual.edu.co', '2001-02-28', 4, '2026-01-20', 1),
(12, 'Camila', 'Vargas', 'camila.vargas@upascual.edu.co', '2003-10-07', 1, '2026-01-20', 3);

-- ============================================
-- 4. perfil_social
-- ============================================
INSERT INTO perfil_social (codigo_perfil, descripcion_personal, area_estudio, fotografia, biografia, tipo_mentoria, codigo_estudiante) OVERRIDING SYSTEM VALUE VALUES
(1, 'Apasionado por el desarrollo backend', 'Desarrollo de software', 'foto_juan.jpg', 'Estudiante de Ingeniería de Sistemas con interés en bases de datos y cloud.', 'Mentoría en bases de datos', 1),
(2, 'Interesada en IA y machine learning', 'Inteligencia artificial', 'foto_maria.jpg', 'Me encanta aprender sobre nuevas tecnologías y compartir conocimiento.', NULL, 2),
(3, 'Futuro ingeniero industrial', 'Gestión de procesos', 'foto_carlos.jpg', 'Enfocado en optimización de procesos y logística.', 'Mentoría en gestión de proyectos', 3),
(4, 'Desarrolladora web frontend', 'Desarrollo web', 'foto_ana.jpg', 'Creando experiencias de usuario atractivas.', NULL, 4),
(5, 'Senior en bases de datos', 'Bases de datos', 'foto_luis.jpg', 'Con experiencia en SQL y NoSQL. Dispuesto a mentorizar.', 'Mentoría en bases de datos y programación', 5),
(6, 'Amante de la logística', 'Logística', 'foto_laura.jpg', 'Interesada en cadena de suministro y proyectos.', NULL, 6),
(7, 'Principiante en programación', 'Fundamentos de programación', 'foto_pedro.jpg', 'Aprendiendo lo básico de algoritmos y estructuras.', NULL, 7),
(8, 'Desarrolladora full stack', 'Desarrollo web', 'foto_sofia.jpg', 'Me gusta crear aplicaciones completas.', NULL, 8),
(9, 'Experto en algoritmos', 'Algoritmos y estructuras', 'foto_diego.jpg', 'Participante en concursos de programación.', 'Mentoría en programación competitiva', 9),
(10, 'Interesada en producción', 'Producción industrial', 'foto_valeria.jpg', 'Optimizando líneas de producción.', NULL, 10),
(11, 'Backend developer', 'Desarrollo backend', 'foto_andres.jpg', 'Apasionado por APIs y microservicios.', NULL, 11),
(12, 'Nueva en el mundo tech', 'Desarrollo de software', 'foto_camila.jpg', 'Explorando el desarrollo web y bases de datos.', NULL, 12);

-- ============================================
-- 5. mentor_materia_habilitada
-- ============================================
INSERT INTO mentor_materia_habilitada (codigo_estudiante, codigo_materia, fecha_habilitacion, certificado) VALUES
(1, 2, '2026-02-01', 'certificado_bd1_juan.pdf'),
(1, 1, '2026-02-01', NULL),
(5, 2, '2026-02-01', 'certificado_bd1_luis.pdf'),
(5, 3, '2026-02-01', 'certificado_estructuras_luis.pdf'),
(9, 2, '2026-02-01', 'certificado_bd1_diego.pdf'),
(9, 1, '2026-02-01', NULL),
(3, 5, '2026-02-01', 'certificado_gestion_carlos.pdf');

-- ============================================
-- 6. sesion_mentoria
-- ============================================
INSERT INTO sesion_mentoria (codigo_sesion, fecha_sesion, hora_sesion, tema, estado, codigo_mentor, codigo_aprendiz, codigo_materia) OVERRIDING SYSTEM VALUE VALUES
(1, '2026-11-10', '14:00', 'Consultas SQL avanzadas', 'programada', 1, 2, 2),
(2, '2026-11-12', '10:00', 'Modelo entidad-relación', 'programada', 5, 7, 2),
(3, '2026-11-05', '16:00', 'Repaso de estructuras de datos', 'realizada', 5, 11, 3),
(4, '2026-11-15', '09:00', 'Introducción a bases de datos', 'programada', 9, 4, 2),
(5, '2026-11-08', '11:00', 'Gestión de proyectos ágiles', 'realizada', 3, 10, 5);

-- ============================================
-- 7. interes
-- ============================================
INSERT INTO interes (codigo_interes, nombre_interes, descripcion) OVERRIDING SYSTEM VALUE VALUES
(1, 'Programación competitiva', 'Participación en concursos de algoritmos'),
(2, 'Inteligencia artificial', 'Aprendizaje automático y redes neuronales'),
(3, 'Desarrollo web', 'Creación de aplicaciones y sitios web'),
(4, 'Videojuegos', 'Desarrollo y análisis de videojuegos'),
(5, 'Robótica', 'Construcción y programación de robots'),
(6, 'Deportes', 'Actividades físicas y competencias'),
(7, 'Música', 'Tocar instrumentos y producir música');

-- ============================================
-- 8. habilidad
-- ============================================
INSERT INTO habilidad (codigo_habilidad, nombre_habilidad, descripcion) OVERRIDING SYSTEM VALUE VALUES
(1, 'Python', 'Programación en Python'),
(2, 'Java', 'Programación en Java'),
(3, 'SQL', 'Lenguaje de consultas estructurado'),
(4, 'JavaScript', 'Programación en JavaScript'),
(5, 'Liderazgo', 'Capacidad de dirigir equipos'),
(6, 'Comunicación', 'Habilidad para expresarse claramente'),
(7, 'Trabajo en equipo', 'Colaboración efectiva');

-- ============================================
-- 9. estudiante_interes
-- ============================================
INSERT INTO estudiante_interes (codigo_estudiante, codigo_interes, fecha_asociacion) VALUES
(1, 1, '2026-02-15'),
(1, 3, '2026-02-15'),
(2, 2, '2026-02-16'),
(3, 5, '2026-02-16'),
(4, 3, '2026-02-17'),
(5, 1, '2026-02-17'),
(5, 2, '2026-02-17'),
(6, 5, '2026-02-18'),
(7, 4, '2026-02-18'),
(8, 3, '2026-02-19'),
(9, 1, '2026-02-19'),
(9, 2, '2026-02-19'),
(10, 6, '2026-02-20'),
(11, 3, '2026-02-20'),
(12, 4, '2026-02-21');

-- ============================================
-- 10. estudiante_habilidad
-- ============================================
INSERT INTO estudiante_habilidad (codigo_estudiante, codigo_habilidad, nivel) VALUES
(1, 1, 'avanzado'),
(1, 3, 'avanzado'),
(2, 2, 'medio'),
(2, 6, 'avanzado'),
(3, 5, 'avanzado'),
(4, 4, 'medio'),
(5, 1, 'avanzado'),
(5, 3, 'avanzado'),
(5, 5, 'medio'),
(6, 7, 'avanzado'),
(7, 1, 'basico'),
(8, 4, 'avanzado'),
(9, 1, 'avanzado'),
(9, 2, 'medio'),
(10, 6, 'medio'),
(11, 3, 'medio'),
(12, 4, 'basico');

-- ============================================
-- 11. tipo_publicacion
-- ============================================
INSERT INTO tipo_publicacion (codigo_tipo_publicacion, nombre_tipo, descripcion) OVERRIDING SYSTEM VALUE VALUES
(1, 'Pregunta', 'Dudas académicas'),
(2, 'Recurso', 'Material de apoyo'),
(3, 'Noticia', 'Noticias de interés'),
(4, 'Meme', 'Contenido humorístico');

-- ============================================
-- 12. publicacion
-- ============================================
INSERT INTO publicacion (codigo_publicacion, contenido, fecha_publicacion, archivo_adjunto, metadatos_dispositivo, codigo_estudiante, codigo_tipo_publicacion) OVERRIDING SYSTEM VALUE VALUES
(1, '¿Alguien tiene apuntes de la clase de bases de datos?', '2026-11-01 10:00:00-05', NULL, '{"navegador": "Chrome", "so": "Windows 10", "conexion": "WiFi"}', 2, 1),
(2, 'Comparto un recurso sobre Python para principiantes', '2026-11-02 14:30:00-05', 'python_basico.pdf', '{"navegador": "Firefox", "so": "Ubuntu", "conexion": "Ethernet"}', 1, 2),
(3, '¡Gran noticia! Abren inscripciones para el hackatón', '2026-11-03 09:15:00-05', NULL, '{"navegador": "Safari", "so": "macOS", "conexion": "WiFi"}', 9, 3),
(4, 'Meme sobre la vida universitaria', '2026-11-03 20:45:00-05', 'meme.jpg', '{"navegador": "Chrome", "so": "Android", "conexion": "4G"}', 4, 4),
(5, '¿Cómo se hace un JOIN en SQL?', '2026-11-04 08:00:00-05', NULL, '{"navegador": "Chrome", "so": "Windows 10", "conexion": "WiFi"}', 7, 1),
(6, 'Les comparto mi repositorio de estructuras de datos', '2026-11-04 16:20:00-05', 'https://github.com/ejemplo/estructuras', '{"navegador": "Edge", "so": "Windows 11", "conexion": "WiFi"}', 5, 2),
(7, 'Noticia: nueva versión de PostgreSQL 16', '2026-11-05 11:00:00-05', NULL, '{"navegador": "Chrome", "so": "Linux", "conexion": "Ethernet"}', 1, 3),
(8, '¿Alguien para estudiar cálculo?', '2026-11-05 18:30:00-05', NULL, '{"navegador": "Firefox", "so": "Windows 10", "conexion": "WiFi"}', 10, 1),
(9, 'Meme de programadores', '2026-11-06 12:00:00-05', 'meme2.png', '{"navegador": "Chrome", "so": "iOS", "conexion": "4G"}', 8, 4),
(10, 'Recurso: guía de JavaScript moderno', '2026-11-06 15:45:00-05', 'js_moderno.pdf', '{"navegador": "Safari", "so": "macOS", "conexion": "WiFi"}', 4, 2),
(11, '¿Cómo funciona la recursión?', '2026-11-07 09:30:00-05', NULL, '{"navegador": "Chrome", "so": "Android", "conexion": "4G"}', 12, 1),
(12, 'Comparto apuntes de gestión de proyectos', '2026-11-07 14:00:00-05', 'gestion_proyectos.pdf', '{"navegador": "Edge", "so": "Windows 10", "conexion": "WiFi"}', 3, 2),
(13, 'Noticia: inteligencia artificial en la educación', '2026-11-08 10:15:00-05', NULL, '{"navegador": "Chrome", "so": "Windows 11", "conexion": "WiFi"}', 2, 3),
(14, 'Meme sobre exámenes', '2026-11-08 19:00:00-05', 'meme3.jpg', '{"navegador": "Firefox", "so": "Linux", "conexion": "Ethernet"}', 6, 4),
(15, '¿Recomendaciones para aprender SQL?', '2026-11-09 08:45:00-05', NULL, '{"navegador": "Chrome", "so": "Windows 10", "conexion": "WiFi"}', 11, 1);

-- ============================================
-- 13. seguidor_estudiante
-- ============================================
INSERT INTO seguidor_estudiante (codigo_seguidor, codigo_seguido, fecha_seguimiento) VALUES
(2, 1, '2026-02-20'),
(2, 5, '2026-02-20'),
(4, 1, '2026-02-21'),
(7, 5, '2026-02-21'),
(7, 9, '2026-02-22'),
(8, 1, '2026-02-22'),
(8, 9, '2026-02-22'),
(10, 3, '2026-02-23'),
(11, 5, '2026-02-23'),
(11, 9, '2026-02-24'),
(12, 1, '2026-02-24'),
(12, 4, '2026-02-24'),
(12, 8, '2026-02-25');

-- ============================================
-- 14. comentario
-- ============================================
INSERT INTO comentario (codigo_comentario, contenido, fecha_comentario, codigo_estudiante, codigo_publicacion) OVERRIDING SYSTEM VALUE VALUES
(1, 'Yo tengo apuntes, te los paso por mensaje.', '2026-11-01 11:00:00-05', 5, 1),
(2, 'Gracias por compartir, muy útil.', '2026-11-02 15:00:00-05', 2, 2),
(3, '¡Excelente! Ya me inscribí.', '2026-11-03 10:00:00-05', 1, 3),
(4, 'Jajaja muy bueno.', '2026-11-03 21:00:00-05', 8, 4),
(5, 'Depende del tipo de JOIN, puedes usar INNER, LEFT, etc.', '2026-11-04 09:00:00-05', 1, 5),
(6, 'Gracias, lo revisaré.', '2026-11-04 17:00:00-05', 11, 6),
(7, 'Interesante artículo.', '2026-11-05 12:00:00-05', 9, 7),
(8, 'Yo me apunto para estudiar cálculo.', '2026-11-05 19:00:00-05', 6, 8),
(9, 'Muy cierto.', '2026-11-06 13:00:00-05', 3, 9),
(10, 'Gracias, justo lo que necesitaba.', '2026-11-06 16:00:00-05', 12, 10),
(11, 'La recursión es cuando una función se llama a sí misma.', '2026-11-07 10:00:00-05', 5, 11),
(12, 'Buen material, gracias.', '2026-11-07 15:00:00-05', 10, 12),
(13, 'La IA está revolucionando todo.', '2026-11-08 11:00:00-05', 1, 13),
(14, 'Jajaja me identifico.', '2026-11-08 20:00:00-05', 2, 14),
(15, 'Te recomiendo el curso de SQL de Codecademy.', '2026-11-09 09:00:00-05', 5, 15);

-- ============================================
-- 15. reaccion
-- ============================================
INSERT INTO reaccion (codigo_estudiante, codigo_publicacion, tipo_reaccion, fecha_reaccion) VALUES
(1, 1, 'me gusta', '2026-11-01 12:00:00-05'),
(5, 1, 'me encanta', '2026-11-01 13:00:00-05'),
(2, 2, 'me gusta', '2026-11-02 16:00:00-05'),
(9, 2, 'me gusta', '2026-11-02 17:00:00-05'),
(1, 3, 'me encanta', '2026-11-03 11:00:00-05'),
(4, 3, 'me gusta', '2026-11-03 12:00:00-05'),
(8, 4, 'me divierte', '2026-11-03 22:00:00-05'),
(3, 4, 'me divierte', '2026-11-03 22:30:00-05'),
(7, 5, 'me gusta', '2026-11-04 10:00:00-05'),
(11, 6, 'me gusta', '2026-11-04 18:00:00-05'),
(9, 7, 'me gusta', '2026-11-05 13:00:00-05'),
(6, 8, 'me gusta', '2026-11-05 20:00:00-05'),
(12, 9, 'me divierte', '2026-11-06 14:00:00-05'),
(2, 10, 'me gusta', '2026-11-06 17:00:00-05'),
(5, 11, 'me encanta', '2026-11-07 11:00:00-05'),
(10, 12, 'me gusta', '2026-11-07 16:00:00-05'),
(1, 13, 'me gusta', '2026-11-08 12:00:00-05'),
(3, 14, 'me divierte', '2026-11-08 21:00:00-05'),
(5, 15, 'me gusta', '2026-11-09 10:00:00-05');

-- ============================================
-- 16. tipo_recurso
-- ============================================
INSERT INTO tipo_recurso (codigo_tipo_recurso, nombre_tipo, descripcion) OVERRIDING SYSTEM VALUE VALUES
(1, 'PDF', 'Documento PDF'),
(2, 'Enlace', 'Enlace web'),
(3, 'Código', 'Código fuente'),
(4, 'Video', 'Video tutorial'),
(5, 'Documento', 'Documento de texto');

-- ============================================
-- 17. recurso_academico
-- ============================================
INSERT INTO recurso_academico (codigo_recurso, titulo, descripcion, url_archivo, fecha_subida, codigo_estudiante, codigo_materia, codigo_tipo_recurso) OVERRIDING SYSTEM VALUE VALUES
(1, 'Apuntes de Bases de Datos', 'Resumen completo del curso', 'https://ejemplo.com/apuntes_bd.pdf', '2026-11-01 09:00:00-05', 1, 2, 1),
(2, 'Guía de Python', 'Introducción a Python', 'https://ejemplo.com/guia_python.pdf', '2026-11-02 10:00:00-05', 2, 1, 1),
(3, 'Repositorio de Estructuras', 'Código de ejemplo', 'https://github.com/ejemplo/estructuras', '2026-11-03 11:00:00-05', 5, 3, 3),
(4, 'Video de SQL JOINs', 'Explicación visual', 'https://youtube.com/watch?v=ejemplo', '2026-11-04 12:00:00-05', 1, 2, 4),
(5, 'Plantilla de Gestión', 'Formato para proyectos', 'https://ejemplo.com/plantilla_gestion.docx', '2026-11-05 13:00:00-05', 3, 5, 5),
(6, 'Tutorial de JavaScript', 'Curso completo', 'https://ejemplo.com/tutorial_js.pdf', '2026-11-06 14:00:00-05', 4, 6, 1),
(7, 'Enlace a documentación de PostgreSQL', 'Documentación oficial', 'https://www.postgresql.org/docs/16/', '2026-11-07 15:00:00-05', 5, 2, 2),
(8, 'Código de ejemplo de recursión', 'Función recursiva en Python', 'https://ejemplo.com/recursion.py', '2026-11-08 16:00:00-05', 9, 3, 3);

-- ============================================
-- 18. valoracion_recurso
-- ============================================
INSERT INTO valoracion_recurso (codigo_estudiante, codigo_recurso, puntuacion, comentario, fecha_valoracion) VALUES
(2, 1, 5, 'Excelentes apuntes', '2026-11-01 10:00:00-05'),
(5, 1, 4, 'Muy completos', '2026-11-01 11:00:00-05'),
(1, 2, 5, 'Muy claro', '2026-11-02 11:00:00-05'),
(7, 2, 4, 'Bueno para empezar', '2026-11-02 12:00:00-05'),
(11, 3, 5, 'El código está muy bien comentado', '2026-11-03 12:00:00-05'),
(2, 4, 5, 'El video explica muy bien', '2026-11-04 13:00:00-05'),
(10, 5, 4, 'Útil para proyectos', '2026-11-05 14:00:00-05'),
(12, 6, 3, 'Podría ser más detallado', '2026-11-06 15:00:00-05'),
(1, 7, 5, 'La documentación oficial es la mejor', '2026-11-07 16:00:00-05'),
(7, 8, 4, 'Ejemplo claro de recursión', '2026-11-08 17:00:00-05');

-- ============================================
-- 19. tipo_grupo
-- ============================================
INSERT INTO tipo_grupo (codigo_tipo_grupo, nombre_tipo, descripcion) OVERRIDING SYSTEM VALUE VALUES
(1, 'Estudio', 'Grupos para estudiar materias'),
(2, 'Hackatón', 'Equipos para competencias de programación'),
(3, 'Club', 'Clubes de interés general');

-- ============================================
-- 20. grupo
-- ============================================
INSERT INTO grupo (codigo_grupo, nombre_grupo, descripcion, fecha_creacion, codigo_estudiante_creador, codigo_tipo_grupo) OVERRIDING SYSTEM VALUE VALUES
(1, 'Grupo de Estudio de Bases de Datos', 'Nos reunimos para estudiar SQL', '2026-03-01', 1, 1),
(2, 'Equipo Hackatón 2026', 'Preparación para el hackatón', '2026-03-05', 9, 2),
(3, 'Club de Programación Competitiva', 'Entrenamiento para concursos', '2026-03-10', 5, 3);

-- ============================================
-- 21. evento
-- ============================================
INSERT INTO evento (codigo_evento, nombre_evento, fecha_evento, hora_evento, lugar, estado, descripcion, codigo_estudiante_creador) OVERRIDING SYSTEM VALUE VALUES
(1, 'Taller de SQL Avanzado', '2026-11-12', '14:00', 'Aula 301', 'programado', 'Taller práctico de consultas avanzadas', 1),
(2, 'Hackatón Interno', '2026-11-15', '08:00', 'Auditorio Principal', 'programado', 'Competencia de programación de 24 horas', 9),
(3, 'Reunión Club de Programación', '2026-11-10', '16:00', 'Sala de Sistemas', 'programado', 'Discusión de problemas de algoritmos', 5);

-- ============================================
-- 22. miembro_grupo
-- ============================================
INSERT INTO miembro_grupo (codigo_estudiante, codigo_grupo, fecha_union, rol) VALUES
(1, 1, '2026-03-01', 'moderador'),
(2, 1, '2026-03-02', 'miembro'),
(7, 1, '2026-03-03', 'miembro'),
(11, 1, '2026-03-04', 'miembro'),
(9, 2, '2026-03-05', 'moderador'),
(5, 2, '2026-03-06', 'miembro'),
(8, 2, '2026-03-07', 'miembro'),
(12, 2, '2026-03-08', 'miembro'),
(5, 3, '2026-03-10', 'moderador'),
(1, 3, '2026-03-11', 'miembro'),
(9, 3, '2026-03-12', 'miembro'),
(11, 3, '2026-03-13', 'miembro');

-- ============================================
-- 23. asistencia_evento
-- ============================================
INSERT INTO asistencia_evento (codigo_estudiante, codigo_evento, fecha_inscripcion, estado_asistencia) VALUES
(2, 1, '2026-11-05', 'inscrito'),
(7, 1, '2026-11-05', 'inscrito'),
(11, 1, '2026-11-06', 'inscrito'),
(1, 2, '2026-11-01', 'inscrito'),
(5, 2, '2026-11-02', 'inscrito'),
(8, 2, '2026-11-03', 'inscrito'),
(9, 2, '2026-11-01', 'inscrito'),
(12, 2, '2026-11-04', 'inscrito'),
(1, 3, '2026-11-05', 'inscrito'),
(9, 3, '2026-11-05', 'inscrito'),
(11, 3, '2026-11-06', 'inscrito');

-- ============================================
-- 24. mensaje
-- ============================================
INSERT INTO mensaje (codigo_mensaje, contenido, fecha_envio, leido, codigo_emisor, codigo_receptor) OVERRIDING SYSTEM VALUE VALUES
(1, 'Hola, ¿me puedes pasar los apuntes de bases de datos?', '2026-11-01 12:00:00-05', true, 2, 1),
(2, 'Claro, te los envío por correo.', '2026-11-01 12:30:00-05', true, 1, 2),
(3, '¿Te gustaría unirte al equipo de hackatón?', '2026-11-02 10:00:00-05', false, 9, 5),
(4, 'Sí, me interesa. ¿Cuándo es la primera reunión?', '2026-11-02 11:00:00-05', true, 5, 9),
(5, 'La reunión es el viernes a las 4 pm.', '2026-11-02 11:30:00-05', true, 9, 5),
(6, 'Gracias por la recomendación de SQL.', '2026-11-03 09:00:00-05', false, 11, 5),
(7, 'De nada, cualquier duda me escribes.', '2026-11-03 10:00:00-05', true, 5, 11);

-- =====================================================================
-- AJUSTE DE SECUENCIAS
-- =====================================================================
-- Como usamos OVERRIDING SYSTEM VALUE, las secuencias no se actualizaron.
-- Las ajustamos al máximo ID insertado + 1 para evitar conflictos futuros.

SELECT setval(pg_get_serial_sequence('programa_academico', 'codigo_programa'), (SELECT MAX(codigo_programa) FROM programa_academico));
SELECT setval(pg_get_serial_sequence('materia_asignatura', 'codigo_materia'), (SELECT MAX(codigo_materia) FROM materia_asignatura));
SELECT setval(pg_get_serial_sequence('estudiante', 'codigo_estudiante'), (SELECT MAX(codigo_estudiante) FROM estudiante));
SELECT setval(pg_get_serial_sequence('perfil_social', 'codigo_perfil'), (SELECT MAX(codigo_perfil) FROM perfil_social));
SELECT setval(pg_get_serial_sequence('sesion_mentoria', 'codigo_sesion'), (SELECT MAX(codigo_sesion) FROM sesion_mentoria));
SELECT setval(pg_get_serial_sequence('interes', 'codigo_interes'), (SELECT MAX(codigo_interes) FROM interes));
SELECT setval(pg_get_serial_sequence('habilidad', 'codigo_habilidad'), (SELECT MAX(codigo_habilidad) FROM habilidad));
SELECT setval(pg_get_serial_sequence('tipo_publicacion', 'codigo_tipo_publicacion'), (SELECT MAX(codigo_tipo_publicacion) FROM tipo_publicacion));
SELECT setval(pg_get_serial_sequence('publicacion', 'codigo_publicacion'), (SELECT MAX(codigo_publicacion) FROM publicacion));
SELECT setval(pg_get_serial_sequence('comentario', 'codigo_comentario'), (SELECT MAX(codigo_comentario) FROM comentario));
SELECT setval(pg_get_serial_sequence('tipo_recurso', 'codigo_tipo_recurso'), (SELECT MAX(codigo_tipo_recurso) FROM tipo_recurso));
SELECT setval(pg_get_serial_sequence('recurso_academico', 'codigo_recurso'), (SELECT MAX(codigo_recurso) FROM recurso_academico));
SELECT setval(pg_get_serial_sequence('tipo_grupo', 'codigo_tipo_grupo'), (SELECT MAX(codigo_tipo_grupo) FROM tipo_grupo));
SELECT setval(pg_get_serial_sequence('grupo', 'codigo_grupo'), (SELECT MAX(codigo_grupo) FROM grupo));
SELECT setval(pg_get_serial_sequence('evento', 'codigo_evento'), (SELECT MAX(codigo_evento) FROM evento));
SELECT setval(pg_get_serial_sequence('mensaje', 'codigo_mensaje'), (SELECT MAX(codigo_mensaje) FROM mensaje));

-- Fin del script de datos de prueba.
