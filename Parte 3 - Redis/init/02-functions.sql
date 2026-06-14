CREATE OR REPLACE FUNCTION fn_calcular_porcentaje_asistencia(
    p_alumno_id INT,
    p_comision_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_alumno_id usuario.usuario_id%TYPE;
    v_comision_id comision.comision_id%TYPE;
    v_total INT;
    v_presentes INT;
BEGIN
    v_alumno_id := p_alumno_id;
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
    WHERE alumno_id = v_alumno_id
      AND comision_id = v_comision_id;

    IF v_total = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND(100.0 * v_presentes / v_total, 2);
END;
$$;

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
