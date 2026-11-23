-- =====================================================================
-- TAREA 6: CONSULTAS DML SOBRE DATOS SEMIESTRUCTURADOS (JSONB) E IoT
-- Red social estudiantil pascualina - Grupo 6
-- SGBD: PostgreSQL 16
-- Fecha: 2026-11-22
--
-- Inventario: 11 consultas + 2 vistas + 3 pruebas EXPLAIN.
-- Cubre: JSONB (publicaciones, preferencias, IoT, logs), JOIN,
-- SUM, COUNT, AVG, MAX, GROUP BY, HAVING, índices GIN y BRIN.
--
-- Ejecutar después del DDL y del script de datos de prueba de Tarea 6.
-- =====================================================================


-- =====================================================================
-- SECCIÓN A: JSONB EN PUBLICACIONES
-- =====================================================================

-- A1. Publicaciones con un hashtag específico.
-- Cubre: operador @> (activador del GIN), JOIN, filtro JSONB array.
SELECT
    p.codigo_publicacion,
    p.contenido,
    p.etiquetas,
    e.nombre || ' ' || e.apellido AS autor
FROM publicacion p
JOIN estudiante e ON p.codigo_estudiante = e.codigo_estudiante
WHERE p.etiquetas @> '["#sql"]'::jsonb
ORDER BY p.fecha_publicacion DESC;

-- A2. Ranking de hashtags más usados.
-- Cubre: jsonb_array_elements_text, COUNT, GROUP BY, ORDER BY.
SELECT
    jsonb_array_elements_text(p.etiquetas) AS hashtag,
    COUNT(*)                                AS total_usos
FROM publicacion p
GROUP BY hashtag
ORDER BY total_usos DESC, hashtag;

-- A3. Publicaciones agrupadas por navegador y sistema operativo.
-- Cubre: extracción con ->>, COUNT, GROUP BY (dos dimensiones JSONB).
SELECT
    p.metadatos_dispositivo->>'navegador' AS navegador,
    p.metadatos_dispositivo->>'so'        AS sistema_operativo,
    COUNT(*)                              AS total_publicaciones
FROM publicacion p
WHERE p.metadatos_dispositivo IS NOT NULL
GROUP BY navegador, sistema_operativo
ORDER BY total_publicaciones DESC;


-- =====================================================================
-- SECCIÓN B: PREFERENCIAS DE NOTIFICACIÓN (JSONB en perfil_social)
-- =====================================================================

-- B1. Estudiantes con notificaciones push activas.
-- Cubre: @> sobre JSONB (usa GIN idx_perfil_preferencias), COUNT.
SELECT COUNT(*) AS estudiantes_push_activo
FROM perfil_social
WHERE preferencias_notificacion @> '{"push": true}'::jsonb;

-- B2. Resumen de canales activos con SUM condicional.
-- Cubre: ->>, CAST a boolean, SUM(CASE WHEN), COUNT.
SELECT
    SUM(CASE WHEN (preferencias_notificacion->>'email')::boolean THEN 1 ELSE 0 END) AS email_activo,
    SUM(CASE WHEN (preferencias_notificacion->>'push')::boolean  THEN 1 ELSE 0 END) AS push_activo,
    SUM(CASE WHEN (preferencias_notificacion->>'sms')::boolean   THEN 1 ELSE 0 END) AS sms_activo,
    COUNT(*) AS total_perfiles
FROM perfil_social
WHERE preferencias_notificacion IS NOT NULL;


-- =====================================================================
-- SECCIÓN C: IoT (lectura_sensor / dispositivo_iot)
-- =====================================================================

-- C1. Aforo promedio y máximo por evento del campus.
-- Cubre: ->> + CAST, AVG, MAX, COUNT, JOIN triple (evento + sensor + dispositivo).
SELECT
    ev.codigo_evento,
    ev.nombre_evento,
    d.nombre_dispositivo                       AS sensor,
    ROUND(AVG((ls.datos->>'personas')::int), 1) AS promedio_personas,
    MAX((ls.datos->>'personas')::int)           AS maximo_personas,
    COUNT(*)                                    AS lecturas
FROM lectura_sensor ls
JOIN dispositivo_iot d ON ls.id_dispositivo = d.id_dispositivo
JOIN evento ev         ON ls.codigo_evento  = ev.codigo_evento
WHERE d.tipo_sensor = 'ocupacion'
  AND ls.datos ? 'personas'
GROUP BY ev.codigo_evento, ev.nombre_evento, d.nombre_dispositivo
ORDER BY promedio_personas DESC;

-- C2. Lecturas que superan el umbral del propio sensor.
-- Cubre: comparación entre dos JSONB distintos (datos vs configuracion), JOIN.
SELECT
    d.nombre_dispositivo                          AS sensor,
    ls.fecha_hora,
    (ls.datos->>'valor')::numeric                 AS valor_medido,
    (d.configuracion->>'umbral_alerta')::numeric  AS umbral
FROM lectura_sensor ls
JOIN dispositivo_iot d ON ls.id_dispositivo = d.id_dispositivo
WHERE d.configuracion ? 'umbral_alerta'
  AND (ls.datos->>'valor')::numeric > (d.configuracion->>'umbral_alerta')::numeric
ORDER BY valor_medido DESC;

-- C3. Promedio de lecturas por tipo de sensor y ubicación.
-- Cubre: AVG, COUNT, GROUP BY sobre atributos relacionales + JSONB.
SELECT
    d.tipo_sensor,
    d.ubicacion,
    ROUND(AVG((ls.datos->>'valor')::numeric), 2) AS promedio_valor,
    COUNT(*)                                     AS lecturas
FROM lectura_sensor ls
JOIN dispositivo_iot d ON ls.id_dispositivo = d.id_dispositivo
WHERE ls.datos ? 'valor'
GROUP BY d.tipo_sensor, d.ubicacion
ORDER BY d.tipo_sensor, promedio_valor DESC;


-- =====================================================================
-- SECCIÓN D: LOGS DE ACTIVIDAD (JSONB en log_actividad)
-- =====================================================================

-- D1. Eventos por tipo (distribución de actividad).
-- Cubre: COUNT, GROUP BY sobre columna relacional.
SELECT
    tipo_evento,
    COUNT(*) AS total_eventos
FROM log_actividad
GROUP BY tipo_evento
ORDER BY total_eventos DESC;

-- D2. Estudiantes con inicios de sesión fallidos.
-- Cubre: @> sobre JSONB (usa GIN idx_log_detalles_gin), JOIN, COUNT, GROUP BY.
SELECT
    e.codigo_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante,
    COUNT(*)                      AS intentos_fallidos
FROM log_actividad l
JOIN estudiante e ON l.codigo_estudiante = e.codigo_estudiante
WHERE l.tipo_evento = 'login'
  AND l.detalles @> '{"exito": false}'::jsonb
GROUP BY e.codigo_estudiante, e.nombre, e.apellido
ORDER BY intentos_fallidos DESC;


-- =====================================================================
-- SECCIÓN E: CONSULTA INTEGRADORA (relacional + JSONB + IoT)
-- =====================================================================

-- E1. Aforo máximo registrado en eventos creados por cada estudiante.
-- Cubre: JOIN triple, MAX, AVG, COUNT DISTINCT, GROUP BY, HAVING.
-- Es la consulta que más se luce: cruza relacional + IoT + JSONB.
SELECT
    e.codigo_estudiante,
    e.nombre || ' ' || e.apellido AS organizador,
    COUNT(DISTINCT ev.codigo_evento)             AS eventos_con_lecturas,
    ROUND(AVG((ls.datos->>'personas')::int), 1)  AS aforo_promedio,
    MAX((ls.datos->>'personas')::int)            AS aforo_maximo
FROM estudiante e
JOIN evento ev          ON ev.codigo_estudiante_creador = e.codigo_estudiante
JOIN lectura_sensor ls  ON ls.codigo_evento             = ev.codigo_evento
JOIN dispositivo_iot d  ON d.id_dispositivo             = ls.id_dispositivo
WHERE d.tipo_sensor = 'ocupacion'
  AND ls.datos ? 'personas'
GROUP BY e.codigo_estudiante, e.nombre, e.apellido
HAVING MAX((ls.datos->>'personas')::int) >= 20
ORDER BY aforo_maximo DESC;


-- =====================================================================
-- SECCIÓN F: VISTAS ANALÍTICAS
-- =====================================================================

-- F1. Vista que aplana los hashtags para dashboards.
CREATE OR REPLACE VIEW v_publicaciones_etiquetas AS
SELECT
    p.codigo_publicacion,
    p.contenido,
    p.fecha_publicacion,
    p.metadatos_dispositivo->>'so'         AS so,
    jsonb_array_elements_text(p.etiquetas) AS hashtag,
    e.nombre || ' ' || e.apellido          AS autor
FROM publicacion p
JOIN estudiante e ON p.codigo_estudiante = e.codigo_estudiante;

-- Prueba
SELECT * FROM v_publicaciones_etiquetas ORDER BY fecha_publicacion DESC LIMIT 10;

-- F2. Vista que resume métricas IoT por evento.
CREATE OR REPLACE VIEW v_resumen_iot_evento AS
SELECT
    ev.codigo_evento,
    ev.nombre_evento,
    ev.fecha_evento,
    AVG(CASE WHEN d.tipo_sensor = 'ocupacion' AND ls.datos ? 'personas'
             THEN (ls.datos->>'personas')::int END)    AS promedio_personas,
    MAX(CASE WHEN d.tipo_sensor = 'ocupacion' AND ls.datos ? 'personas'
             THEN (ls.datos->>'personas')::int END)    AS maximo_personas,
    AVG(CASE WHEN d.tipo_sensor = 'temperatura' AND ls.datos ? 'valor'
             THEN (ls.datos->>'valor')::numeric END)   AS promedio_temperatura,
    COUNT(*)                                           AS lecturas_totales
FROM evento ev
JOIN lectura_sensor ls ON ls.codigo_evento  = ev.codigo_evento
JOIN dispositivo_iot d ON d.id_dispositivo  = ls.id_dispositivo
GROUP BY ev.codigo_evento, ev.nombre_evento, ev.fecha_evento;

-- Prueba
SELECT * FROM v_resumen_iot_evento ORDER BY fecha_evento;


-- =====================================================================
-- SECCIÓN G: PRUEBAS DE OPTIMIZACIÓN (evidencia para el informe)
-- =====================================================================

-- G1. Uso del GIN en etiquetas de publicación.
EXPLAIN ANALYZE
SELECT * FROM publicacion WHERE etiquetas @> '["#sql"]'::jsonb;

-- G2. Uso del GIN en lecturas IoT (filtro por estado dentro del JSONB).
EXPLAIN ANALYZE
SELECT * FROM lectura_sensor WHERE datos @> '{"estado": "alerta_calor"}'::jsonb;

-- G3. Uso del GIN en logs (intentos fallidos).
EXPLAIN ANALYZE
SELECT * FROM log_actividad WHERE detalles @> '{"exito": false}'::jsonb;

-- =====================================================================
-- FIN DEL SCRIPT
-- =====================================================================
