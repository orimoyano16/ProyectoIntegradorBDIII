-- Parte A - Lógica Procedural

-- 1. Función (FUNCTION) - STABLE
CREATE OR REPLACE FUNCTION fn_calcular_porcentaje_asistencia(
    p_alumno_id   INT,
    p_comision_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_alumno_id   usuario.usuario_id%TYPE;
    v_comision_id comision.comision_id%TYPE;
    v_total       INT;
    v_presentes   INT;
BEGIN
    v_alumno_id   := p_alumno_id;
    v_comision_id := p_comision_id;

    IF NOT EXISTS (
        SELECT 1 FROM usuario WHERE usuario_id = v_alumno_id
    ) THEN
        RAISE EXCEPTION 'El alumno con id % no existe', v_alumno_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM comision WHERE comision_id = v_comision_id
    ) THEN
        RAISE EXCEPTION 'La comisión con id % no existe', v_comision_id;
    END IF;

    SELECT
        COUNT(*),
        COALESCE(SUM(CASE WHEN UPPER(estado) = 'PRESENTE' THEN 1 ELSE 0 END), 0)
    INTO v_total, v_presentes
    FROM asistencia
    WHERE alumno_id   = v_alumno_id
      AND comision_id = v_comision_id;

    IF v_total = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND(100.0 * v_presentes / v_total, 2);
END;
$$;

-- 2. Función (FUNCTION) - IMMUTABLE
CREATE OR REPLACE FUNCTION fn_clasificar_nivel_asistencia(
    p_porcentaje NUMERIC
)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF p_porcentaje IS NULL THEN
        RETURN 'sin_datos';
    ELSIF p_porcentaje >= 75 THEN
        RETURN 'regular';
    ELSIF p_porcentaje >= 50 THEN
        RETURN 'en_riesgo';
    ELSE
        RETURN 'critico';
    END IF;
END;
$$;

-- 3. Procedimiento Almacenado (PROCEDURE)
CREATE OR REPLACE PROCEDURE sp_inscribir_alumno_comision(
    IN  p_alumno_id   INT,
    IN  p_comision_id INT,
    OUT p_inscripcion_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_alumno      usuario%ROWTYPE;
    v_comision    comision%ROWTYPE;
    v_materia     materia%ROWTYPE;
    v_inscripcion inscripcion%ROWTYPE;
    v_alumno_id   usuario.usuario_id%TYPE;
    v_comision_id comision.comision_id%TYPE;
BEGIN
    v_alumno_id   := p_alumno_id;
    v_comision_id := p_comision_id;

    SELECT * INTO v_alumno
    FROM usuario
    WHERE usuario_id = v_alumno_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró al alumno con id %', v_alumno_id;
    END IF;

    SELECT * INTO v_comision
    FROM comision
    WHERE comision_id = v_comision_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la comisión con id %', v_comision_id;
    END IF;

    SELECT * INTO v_materia
    FROM materia
    WHERE materia_id = v_comision.materia_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La comisión % no tiene una materia válida asociada', v_comision_id;
    END IF;

    IF v_materia.carrera_id IS DISTINCT FROM v_alumno.carrera_id THEN
        RAISE EXCEPTION
            'El alumno % pertenece a otra carrera y no puede inscribirse a esta comisión',
            v_alumno_id;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM inscripcion
        WHERE alumno_id   = v_alumno_id
          AND comision_id = v_comision_id
    ) THEN
        RAISE EXCEPTION
            'El alumno % ya está inscripto en la comisión %',
            v_alumno_id, v_comision_id;
    END IF;

    INSERT INTO inscripcion (alumno_id, comision_id, fecha_inscripcion)
    VALUES (v_alumno_id, v_comision_id, CURRENT_DATE)
    RETURNING * INTO v_inscripcion;

    p_inscripcion_id := v_inscripcion.inscripcion_id;

    RAISE NOTICE
        'Inscripción exitosa: alumno % (% %) → comisión % (materia: %)',
        v_alumno.usuario_id,
        v_alumno.nombre,
        v_alumno.apellido,
        v_comision.comision_id,
        v_materia.nombre;
END;
$$;

-- 4. Abstracción (permisos)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_asistencias') THEN
        CREATE ROLE app_asistencias NOLOGIN;
    END IF;
END;
$$;

REVOKE ALL ON TABLE carrera, usuario, materia, comision, inscripcion, asistencia
    FROM PUBLIC;

REVOKE ALL ON TABLE carrera, usuario, materia, comision, inscripcion, asistencia
    FROM app_asistencias;

GRANT EXECUTE ON FUNCTION fn_calcular_porcentaje_asistencia(INT, INT)
    TO app_asistencias;

GRANT EXECUTE ON FUNCTION fn_clasificar_nivel_asistencia(NUMERIC)
    TO app_asistencias;

GRANT EXECUTE ON PROCEDURE sp_inscribir_alumno_comision(INT, INT, INT)
    TO app_asistencias;
