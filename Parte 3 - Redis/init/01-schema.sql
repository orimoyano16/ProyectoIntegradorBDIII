CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    fecha TIMESTAMP,
    usuario VARCHAR(35),
    codigo_error VARCHAR(100),
    mensaje_error VARCHAR(100)
);

CREATE TABLE carrera (
    carrera_id SERIAL PRIMARY KEY,
    nombre_carrera VARCHAR(60) NOT NULL,
    duracion VARCHAR(35) NOT NULL
);

CREATE TABLE usuario (
    usuario_id SERIAL PRIMARY KEY,
    nombre VARCHAR(35) NOT NULL,
    apellido VARCHAR(35) NOT NULL,
    email VARCHAR(60) NOT NULL,
    password_hash TEXT NOT NULL,
    dni BIGINT UNIQUE NOT NULL,
    rol INT NOT NULL,
    carrera_id INT NOT NULL,
    CONSTRAINT fk_usuario_carrera
        FOREIGN KEY (carrera_id)
        REFERENCES carrera (carrera_id)
);

CREATE TABLE materia (
    materia_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    carrera_id INT,
    CONSTRAINT fk_materia_carrera
        FOREIGN KEY (carrera_id)
        REFERENCES carrera (carrera_id)
);

CREATE TABLE comision (
    comision_id SERIAL PRIMARY KEY,
    materia_id INT,
    CONSTRAINT fk_comision_materia
        FOREIGN KEY (materia_id)
        REFERENCES materia (materia_id),
    profesor_id INT,
    CONSTRAINT fk_comision_profesor
        FOREIGN KEY (profesor_id)
        REFERENCES usuario (usuario_id),
    turno TEXT,
    aula TEXT,
    ciclo_lectivo INT
);

CREATE TABLE inscripcion (
    inscripcion_id SERIAL PRIMARY KEY,
    alumno_id INT,
    CONSTRAINT fk_inscripcion_alumno
        FOREIGN KEY (alumno_id)
        REFERENCES usuario (usuario_id),
    comision_id INT,
    CONSTRAINT fk_inscripcion_comision
        FOREIGN KEY (comision_id)
        REFERENCES comision (comision_id),
    fecha_inscripcion DATE NOT NULL
);

CREATE TABLE asistencia (
    id_asistencia SERIAL PRIMARY KEY,
    alumno_id INT,
    CONSTRAINT fk_asistencia_alumno
        FOREIGN KEY (alumno_id)
        REFERENCES usuario (usuario_id),
    comision_id INT,
    CONSTRAINT fk_asistencia_comision
        FOREIGN KEY (comision_id)
        REFERENCES comision (comision_id),
    fecha DATE,
    estado VARCHAR(20),
    observacion TEXT
);

CREATE INDEX idx_usuario_dni ON usuario (dni);
