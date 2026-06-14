--CREAMOS PROCEDIMIENTO PARA REGISTRAR INSCRIPCIONES Y AUDITAR ERRORES  

CREATE OR REPLACE PROCEDURE registrar_inscripcion(
    p_alumno_id BIGINT,
    p_comision_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlstate VARCHAR(5);
    v_message TEXT;
BEGIN
    -- 1. Intentamos realizar la inserción en tu tabla inscripcion
    INSERT INTO inscripcion (alumno_id, comision_id, fecha_inscripcion)
    VALUES (p_alumno_id, p_comision_id, CURRENT_TIMESTAMP);
    
    RAISE NOTICE 'Inscripción registrada con éxito.';

EXCEPTION 
    -- 2. Si ocurre CUALQUIER error (ej. llave foránea o registro duplicado, O ID fuera de rango))
    WHEN OTHERS THEN
        
        -- 3. Obtenemos los detalles del error
        GET STACKED DIAGNOSTICS 
            v_sqlstate = RETURNED_SQLSTATE,
            v_message  = MESSAGE_TEXT;
            
        -- 4. Registramos el error en tu tabla audit_logs
        INSERT INTO audit_logs (fecha, usuario, codigo_error, mensaje_error)
        VALUES (
            CURRENT_TIMESTAMP, 
            current_user,       -- Usuario de la BD que ejecutó el procedimiento
            v_sqlstate,        
            v_message          
        );
        
        -- 5. (Opcional) Notificamos al usuario o aplicación que falló, pero que ya fue registrado
        RAISE NOTICE 'ATENCIÓN: Ocurrió un error (%). Ha sido registrado en audit_logs.', v_sqlstate;
END $$;



--lo probamos 
-- Llamamos al procedimiento con un alumno_id (9999999999999999) y comision_id (8888888888) que no existen
CALL registrar_inscripcion(9999999999999,888888888 );



-- ahora consultamos la tabla de audit logs 
SELECT id, fecha, usuario, codigo_error, mensaje_error 
FROM audit_logs 
ORDER BY fecha DESC;



