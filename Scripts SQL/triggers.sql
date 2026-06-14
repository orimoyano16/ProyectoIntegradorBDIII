-- Creamos la funcion con trigger

CREATE OR REPLACE FUNCTION fn_auditar_cambio_asistencia()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlstate VARCHAR(5);
    v_message TEXT;
BEGIN
    -- Validamos si es una actualización (UPDATE) y si el estado cambió
    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.estado IS DISTINCT FROM NEW.estado) THEN
            
            -- Ejemplo de uso de OLD y NEW: Guardamos en el log el cambio de estado
            INSERT INTO audit_logs (fecha, usuario, codigo_error, mensaje_error)
            VALUES (
                CURRENT_TIMESTAMP,
                current_user,
                '00000', -- Código personalizado 
                format('Cambio de estado en asistencia_id %s: Pasó de "%s" a "%s"', 
                       OLD.id_asistencia, OLD.estado, NEW.estado)
            );
        END IF;
    END IF;

    -- En triggers AFTER, se debe retornar NEW si todo sale bien
    RETURN NEW;

EXCEPTION 
    WHEN OTHERS THEN
        -- Si por alguna razón falla el INSERT en audit_logs, capturamos el error de sistema
        GET STACKED DIAGNOSTICS 
            v_sqlstate = RETURNED_SQLSTATE,
            v_message  = MESSAGE_TEXT;
            
        -- Volvemos a intentar registrar el error real del sistema
        INSERT INTO audit_logs (fecha, usuario, codigo_error, mensaje_error)
        VALUES (CURRENT_TIMESTAMP, current_user, v_sqlstate, 'Fallo en Trigger: ' || v_message);
        
        RETURN NEW;
END $$;


-- creamos el disparador 
CREATE OR REPLACE TRIGGER trg_auditoria_asistencia
AFTER UPDATE ON asistencia
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_cambio_asistencia();


--supongamos que tenemosuna asistencia con id 1 y estado 'Ausente'. Ejecuta un UPDATE:
UPDATE asistencia 
SET estado = 'Presente' 
WHERE id_asistencia = 1;



-- revisamos la tabla de logs 
SELECT * FROM audit_logs ORDER BY fecha DESC;

--Al hacer el UPDATE, el trigger se activa en silencio (tras bambalinas) sin que tú tengas que llamar a ningún procedimiento.