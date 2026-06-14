-- D. Seguridad y Blindaje (Hardening)
-- Privilegio Mínimo

-- 3. Procedimiento Almacenado (PROCEDURE)-
CREATE OR REPLACE PROCEDURE sp_inscribir_alumno_comision( 
    IN  p_alumno_id   INT,
    IN  p_comision_id INT,
    OUT p_inscripcion_id INT
)
LANGUAGE plpgsql
security definer 
set search_path = public
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

