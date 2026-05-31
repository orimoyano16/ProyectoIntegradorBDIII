-- Parte A - Pruebas

-- Datos de prueba
TRUNCATE TABLE
    asistencia,
    inscripcion,
    comision,
    materia,
    usuario,
    carrera,
    audit_logs
RESTART IDENTITY CASCADE;

INSERT INTO carrera (nombre_carrera, duracion) VALUES
    ('Ingeniería en Sistemas', '5 años'),
    ('Abogacía',               '5 años');

INSERT INTO materia (nombre, carrera_id) VALUES
    ('Base de Datos III', 1),
    ('Programación Web',  1),
    ('Derecho Civil',     2);

INSERT INTO usuario (nombre, apellido, email, password_hash, dni, rol, carrera_id) VALUES
    ('Roman',    'Acuña',    'roman@test.com',  'hash1', 40123456, 0, 1),
    ('Santiago', 'Marranti', 'santi@test.com',  'hash2', 40234567, 1, 1),
    ('Oriana',   'Moyano',   'ori@test.com',    'hash3', 40345678, 0, 1),
    ('Ariadna',  'Santillan','ariadna@test.com','hash4', 40456789, 0, 2);

INSERT INTO comision (materia_id, profesor_id, turno, aula, ciclo_lectivo) VALUES
    (1, 2, 'MAÑANA', 'Aula 101', 2026),
    (2, 2, 'TARDE',  'Lab 3',    2026),
    (3, 2, 'NOCHE',  'Aula 205', 2026);

INSERT INTO inscripcion (alumno_id, comision_id, fecha_inscripcion) VALUES
    (1, 1, '2026-03-01'),
    (3, 1, '2026-03-01');

INSERT INTO asistencia (alumno_id, comision_id, fecha, estado, observacion) VALUES
    (1, 1, '2026-03-10', 'PRESENTE', NULL),
    (1, 1, '2026-03-12', 'PRESENTE', NULL),
    (1, 1, '2026-03-14', 'AUSENTE',  'Justificada por certificado médico'),
    (1, 1, '2026-03-17', 'PRESENTE', NULL),
    (3, 1, '2026-03-10', 'PRESENTE', NULL),
    (3, 1, '2026-03-12', 'AUSENTE',  NULL),
    (3, 1, '2026-03-14', 'AUSENTE',  NULL),
    (3, 1, '2026-03-17', 'PRESENTE', NULL);

-- Pruebas (ejecutar después de Parte A - Logica Procedural.sql)

-- Prueba 1
SELECT
    fn_calcular_porcentaje_asistencia(1, 1) AS porcentaje_alumno_1,
    fn_clasificar_nivel_asistencia(
        fn_calcular_porcentaje_asistencia(1, 1)
    ) AS nivel_alumno_1;

-- Prueba 2
SELECT
    fn_calcular_porcentaje_asistencia(3, 1) AS porcentaje_alumno_3,
    fn_clasificar_nivel_asistencia(
        fn_calcular_porcentaje_asistencia(3, 1)
    ) AS nivel_alumno_3;

-- Prueba 3
SELECT fn_calcular_porcentaje_asistencia(999, 1);

-- Prueba 4
DO $$
DECLARE
    v_id inscripcion.inscripcion_id%TYPE;
BEGIN
    CALL sp_inscribir_alumno_comision(1, 2, v_id);
    RAISE NOTICE 'Prueba 4 OK — inscripcion_id: %', v_id;
END;
$$;

-- Prueba 5
DO $$
DECLARE
    v_id inscripcion.inscripcion_id%TYPE;
BEGIN
    CALL sp_inscribir_alumno_comision(1, 1, v_id);
END;
$$;

-- Prueba 6
DO $$
DECLARE
    v_id inscripcion.inscripcion_id%TYPE;
BEGIN
    CALL sp_inscribir_alumno_comision(4, 1, v_id);
END;
$$;

-- Prueba 7
SELECT
    i.inscripcion_id,
    i.alumno_id,
    i.comision_id,
    i.fecha_inscripcion,
    u.nombre,
    u.apellido,
    m.nombre AS materia
FROM inscripcion i
JOIN usuario  u ON i.alumno_id   = u.usuario_id
JOIN comision c ON i.comision_id = c.comision_id
JOIN materia  m ON c.materia_id  = m.materia_id
WHERE i.alumno_id = 1
ORDER BY i.inscripcion_id;
