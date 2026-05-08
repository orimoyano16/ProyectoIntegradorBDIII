create database asistencia_institucional_db;

create table audit_logs(
	id serial primary key,
	fecha timestamp,
	usuario varchar(35),
	codigo_error varchar(100),
	mensaje_error varchar(100)
);

create table carrera (
	carrera_id serial primary key,
	nombre_carrera varchar(60) not null,
	duracion varchar(35) not null
);

create table usuario (
	usuario_id serial primary key,
	nombre varchar(35) not null,
	apellido varchar(35) not null,
	email varchar(60) not null,
	password_hash text not null,
	dni bigint unique not null,
	rol int not null,
	carrera_id int not null,
	constraint carrera_id
		foreign key (carrera_id)
		references carrera(carrera_id)
);

create table materia (
	materia_id serial primary key,
	nombre varchar(50),
	carrera_id int,
	constraint carrera_id
		foreign key (carrera_id)
		references carrera(carrera_id)
);

create table comision (
	comision_id serial primary key,
	materia_id int,
	constraint fk_comision_materia
		foreign key (materia_id)
		references materia(materia_id),
	profesor_id int,
	constraint profesor_id
		foreign key (profesor_id)
		references usuario(usuario_id),
	turno text,
	aula text,
	ciclo_lectivo int
);

create table inscripcion (
	inscripcion_id serial primary key,
	alumno_id int,
	constraint alumno_id
		foreign key (alumno_id)
		references usuario(usuario_id),
	comision_id int,
	constraint fk_inscripcion_comision
		foreign key (comision_id)
		references comision(comision_id),
	fecha_inscripcion date not null
);

create table asistencia(
	id_asistencia serial primary key,
	alumno_id int,
	constraint alumno_id
		foreign key (alumno_id)
		references usuario(usuario_id),
	comision_id int,
	constraint fk_asistencia_comision
		foreign key (comision_id)
		references comision(comision_id),
	fecha date,
	estado varchar(20),
	observacion text
);
----------------------------------------------------------------------

-- CTE (Common Table Expressions)

-- CTE 1: Alumnos con asistencia baja (< 75%)
WITH asistencias_alumno AS (
    SELECT 
        alumno_id,
        COUNT(*) AS total_clases,
        SUM(CASE WHEN estado = 'presente' THEN 1 ELSE 0 END) AS presentes
    FROM asistencia
    GROUP BY alumno_id
)
SELECT 
    u.nombre,
    u.apellido,
    a.total_clases,
    a.presentes,
    ROUND(100.0 * a.presentes / a.total_clases, 2) AS porcentaje
FROM asistencias_alumno a
JOIN usuario u ON a.alumno_id = u.usuario_id
WHERE ROUND(100.0 * a.presentes / a.total_clases, 2) < 75;

-- CTE 2: Alumnos inscriptos por comisión
WITH alumnos_por_comision AS (
    SELECT 
        comision_id,
        COUNT(*) AS cantidad_alumnos
    FROM inscripcion
    GROUP BY comision_id
)
SELECT 
    c.comision_id,
    m.nombre AS materia,
    ac.cantidad_alumnos
FROM alumnos_por_comision ac
JOIN comision c ON ac.comision_id = c.comision_id
JOIN materia m ON c.materia_id = m.materia_id;

-- CTE 3: Alumnos que nunca faltaron (asistencia perfecta)
WITH asistencia_perfecta AS (
    SELECT 
        alumno_id,
        COUNT(*) AS total_clases,
        SUM(CASE WHEN estado = 'ausente' THEN 1 ELSE 0 END) AS ausencias
    FROM asistencia
    GROUP BY alumno_id
    HAVING SUM(CASE WHEN estado = 'ausente' THEN 1 ELSE 0 END) = 0
)
SELECT 
    u.nombre,
    u.apellido,
    ap.total_clases
FROM asistencia_perfecta ap
JOIN usuario u ON ap.alumno_id = u.usuario_id;

-- CTE 4: Alumnos con más del 90% de asistencia
WITH buena_asistencia AS (
    SELECT 
        alumno_id,
        COUNT(*) AS total_clases,
        SUM(CASE WHEN estado = 'presente' THEN 1 ELSE 0 END) AS presentes,
        ROUND(100.0 * SUM(CASE WHEN estado = 'presente' THEN 1 ELSE 0 END) / COUNT(*), 2) AS porcentaje
    FROM asistencia
    GROUP BY alumno_id
)
SELECT 
    u.nombre,
    u.apellido,
    buena_asistencia.porcentaje
FROM buena_asistencia
JOIN usuario u ON buena_asistencia.alumno_id = u.usuario_id
WHERE buena_asistencia.porcentaje > 90;

-- CTE 5: Alumnos y cuántas materias tienen (inscripciones distintas)
WITH materias_por_alumno AS (
    SELECT 
        i.alumno_id,
        COUNT(DISTINCT c.materia_id) AS cantidad_materias
    FROM inscripcion i
    JOIN comision c ON i.comision_id = c.comision_id
    GROUP BY i.alumno_id
)
SELECT 
    u.nombre,
    u.apellido,
    mpa.cantidad_materias
FROM materias_por_alumno mpa
JOIN usuario u ON mpa.alumno_id = u.usuario_id
ORDER BY mpa.cantidad_materias DESC;

--------------------------------------------------------------------------------------
-- WINDOW FUNCTIONS

-- Window 1: Ranking de alumnos por asistencia (por comisión)
SELECT 
    u.nombre,
    u.apellido,
    a.comision_id,
    COUNT(*) AS total_clases,
    SUM(CASE WHEN a.estado = 'presente' THEN 1 ELSE 0 END) AS presentes,
    RANK() OVER (PARTITION BY a.comision_id ORDER BY SUM(CASE WHEN a.estado = 'presente' THEN 1 ELSE 0 END) DESC) AS ranking
FROM asistencia a
JOIN usuario u ON a.alumno_id = u.usuario_id
GROUP BY u.nombre, u.apellido, a.comision_id;

-- Window 2: Asistencia anterior de cada alumno (LAG)
SELECT 
    u.nombre,
    u.apellido,
    a.fecha,
    a.estado,
    LAG(a.estado) OVER (PARTITION BY a.alumno_id ORDER BY a.fecha) AS estado_clase_anterior
FROM asistencia a
JOIN usuario u ON a.alumno_id = u.usuario_id
ORDER BY a.alumno_id, a.fecha;

-- Window 3: Número de asistencia por alumno (ROW_NUMBER)
SELECT 
    u.nombre,
    u.apellido,
    a.fecha,
    a.estado,
    ROW_NUMBER() OVER (PARTITION BY a.alumno_id ORDER BY a.fecha) AS nro_asistencia_registrada
FROM asistencia a
JOIN usuario u ON a.alumno_id = u.usuario_id;

-- Window 4: Próximo estado de asistencia (LEAD)
SELECT 
    u.nombre,
    u.apellido,
    a.fecha,
    a.estado,
    LEAD(a.estado) OVER (PARTITION BY a.alumno_id ORDER BY a.fecha) AS estado_clase_siguiente
FROM asistencia a
JOIN usuario u ON a.alumno_id = u.usuario_id
ORDER BY a.alumno_id, a.fecha;

-- Window 5: Ausencias consecutivas (detectar si la anterior también fue ausente)
SELECT 
    u.nombre,
    u.apellido,
    a.fecha,
    a.estado,
    LAG(a.estado) OVER (PARTITION BY a.alumno_id ORDER BY a.fecha) AS clase_anterior,
    CASE 
        WHEN a.estado = 'ausente' AND LAG(a.estado) OVER (PARTITION BY a.alumno_id ORDER BY a.fecha) = 'ausente' 
        THEN 'ALERTA: Ausencia consecutiva'
        ELSE 'Normal'
    END AS alerta
FROM asistencia a
JOIN usuario u ON a.alumno_id = u.usuario_id
ORDER BY a.alumno_id, a.fecha;


-- CTE + WINDOW FUNCTION (Combinadas)

-- Combinada 1: CTE + Ranking general
WITH asistencias_por_alumno AS (
    SELECT 
        alumno_id,
        comision_id,
        COUNT(*) AS total_clases,
        SUM(CASE WHEN estado = 'presente' THEN 1 ELSE 0 END) AS presentes
    FROM asistencia
    GROUP BY alumno_id, comision_id
)
SELECT 
    u.nombre,
    u.apellido,
    ap.comision_id,
    ap.total_clases,
    ap.presentes,
    ROUND(100.0 * ap.presentes / ap.total_clases, 2) AS porcentaje,
    RANK() OVER (ORDER BY ROUND(100.0 * ap.presentes / ap.total_clases, 2) DESC) AS ranking_general
FROM asistencias_por_alumno ap
JOIN usuario u ON ap.alumno_id = u.usuario_id;

-- Combinada 2: Mejor alumno por comisión (CTE + RANK)
WITH asistencia_comision AS (
    SELECT 
        a.alumno_id,
        u.nombre,
        u.apellido,
        a.comision_id,
        SUM(CASE WHEN a.estado = 'presente' THEN 1 ELSE 0 END) AS presentes,
        RANK() OVER (PARTITION BY a.comision_id ORDER BY SUM(CASE WHEN a.estado = 'presente' THEN 1 ELSE 0 END) DESC) AS ranking
    FROM asistencia a
    JOIN usuario u ON a.alumno_id = u.usuario_id
    GROUP BY a.alumno_id, u.nombre, u.apellido, a.comision_id
)
SELECT 
    comision_id,
    nombre,
    apellido,
    presentes,
    ranking
FROM asistencia_comision
WHERE ranking = 1;
	
