INSERT INTO carrera (nombre_carrera, duracion)
SELECT 
    CASE (i % 5)
        WHEN 0 THEN 'Ingeniería en Sistemas'
        WHEN 1 THEN 'Abogacía'
        WHEN 2 THEN 'Medicina'
        WHEN 3 THEN 'Arquitectura'
        ELSE 'Contador Público'
    END || ' ' || i,
    (3 + (random() * 3)::int) || ' años'
FROM generate_series(1, 200000) AS i;

INSERT INTO materia (nombre, carrera_id)
SELECT 
    'Materia ' || i,
    i
FROM generate_series(1, 200000) AS i;

INSERT INTO usuario(nombre, apellido, email, password_hash, dni, rol, carrera_id)
SELECT 
    'Nombre ' || i,
    'Apellido ' || i,
    'email' || i || '@gmail.com',
    'Password ' || i,
    i,
    (random() * 2)::int,
    i
FROM generate_series(1, 200000) as i;

INSERT INTO comision(materia_id, profesor_id, turno, aula, ciclo_lectivo)
SELECT 
    i,
    i,
    CASE (i % 3)
        WHEN 0 THEN 'TARDE'
        WHEN 1 THEN 'NOCHE'
        ELSE 'MAÑANA'
    END,
    CASE ((random() * 3)::int)
        WHEN 0 THEN 'Sala de Proyeccion'
        WHEN 1 THEN 'Laboratorio'
        ELSE 'Aula'
    END || ' ' || i,
    (random() * 5)::int
FROM generate_series(1, 200000) as i;

INSERT INTO inscripcion(alumno_id, comision_id, fecha_inscripcion)
SELECT 
    i,
    i,
    now()
FROM generate_series(1, 200000) as i;

INSERT INTO asistencia(alumno_id, comision_id, fecha, asistio, observacion)
SELECT 
    i,
    i,
    now(),
    CASE ((random() * 1)::int)
        WHEN 0 THEN true
        ELSE false
    END,
    'Observacion ' || i
FROM generate_series(1, 200000) as i;