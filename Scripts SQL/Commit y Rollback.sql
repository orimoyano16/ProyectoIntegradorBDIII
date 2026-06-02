-- 1. Iniciamos
BEGIN;

-- 2. Insertamos a Ana (Cambiamos el rol 'alumno' por el número 2, y el DNI sin comillas)
INSERT INTO usuario (usuario_id, dni, nombre, apellido, email, password_hash, rol, carrera_id)
VALUES (80999910, 55666777, 'Ana', 'López', 'ana@email.com', 'hash123', 2, 1);

-- 3. Punto de guardado
SAVEPOINT sp_antes_inscripcion;

-- 4. El error forzado (Comisión que no existe)
INSERT INTO inscripcion (alumno_id, comision_id, fecha_inscripcion)
VALUES (8000, 99999, CURRENT_TIMESTAMP);

-- 5. El rescate
ROLLBACK TO SAVEPOINT sp_antes_inscripcion;

-- 6. El registro de auditoría
INSERT INTO audit_logs (fecha, usuario, codigo_error, mensaje_error)
VALUES (CURRENT_TIMESTAMP, current_user, 'WARN', 'Fallo al inscribir. ROLLBACK TO SAVEPOINT exitoso.');

-- 7. Confirmación final
COMMIT;

--1. Comprobar que "Ana" sobrevivió al error:
SELECT * FROM usuario WHERE email = 'ana@email.com';
--2. Comprobar que la inscripción se canceló:
SELECT * FROM inscripcion WHERE comision_id = 99999;
--3. Comprobar la auditoría automática:
SELECT * FROM audit_logs ORDER BY fecha DESC LIMIT 1;

-----------------------------------------------------
-- PROCEDIMIENTO ALMACENADO
-----------------------------------------------------

CREATE OR REPLACE PROCEDURE registrar_usuario(
    p_dni INT, 
    p_nombre VARCHAR, 
    p_apellido VARCHAR, 
    p_email VARCHAR, 
    p_carrera_id INT, 
    p_comision_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nuevo_usuario_id INT;
    v_sqlstate VARCHAR(5);
    v_message TEXT;
BEGIN
    -- =========================================================
    -- 1. OPERACIÓN CRÍTICA (Si falla, aborta todo automáticamente)
    -- =========================================================
    INSERT INTO usuario (dni, nombre, apellido, email, password_hash, rol, carrera_id)
    VALUES (p_dni, p_nombre, p_apellido, p_email, 'default123', 2, p_carrera_id)
    RETURNING usuario_id INTO v_nuevo_usuario_id;
    
    -- =========================================================
    -- 2. MANEJO DE ERRORES PARCIALES (Actúa como SAVEPOINT implicitamente en el momento que el motor entra al bloque begin)
    -- =========================================================
    BEGIN
        INSERT INTO inscripcion (alumno_id, comision_id, fecha_inscripcion)
        VALUES (v_nuevo_usuario_id, p_comision_id, CURRENT_TIMESTAMP);
        
	-- Al entrar en el exception, se realiza un rollback del insert de inscripcion.
	-- Es decir, que todo lo que hizo este bloque begin se descarta.
    EXCEPTION WHEN OTHERS THEN 
        -- Si la inscripción falla, se revierte SOLO la inscripción, salvando al usuario
        GET STACKED DIAGNOSTICS v_sqlstate = RETURNED_SQLSTATE, v_message = MESSAGE_TEXT;
        
        INSERT INTO audit_logs (fecha, usuario, codigo_error, mensaje_error)
        VALUES (CURRENT_TIMESTAMP, current_user, v_sqlstate, v_message);
        
        RAISE NOTICE 'Advertencia: Alumno %, pero no se pudo inscribir. Error: %', p_nombre, v_message;
    END;

    -- =========================================================
    -- 3. ATOMICIDAD: CONFIRMACIÓN EXITOSA
    -- =========================================================
    -- Ahora que no hay un EXCEPTION general vigilando, el COMMIT funcionará perfecto.
	-- Si quisieramos controlar errores en este bloque begin, habria que borrar el commit e implementar el exception when others then
	-- porque al entrar al exception ese, ya hace un rollback implicito, si no entra en el, se hace un commit de manera implicita.
    COMMIT;
    RAISE NOTICE 'Transacción finalizada. El registro de % es seguro.', p_nombre;

END $$;

CALL registrar_usuario(
    25522323,              -- p_dni 
    'Pedro',               -- p_nombre
    'Sánchez',             -- p_apellido
    'pedro@ejemplo.com',   -- p_email
    1,                     -- p_carrera_id 
    201000                  -- p_comision_id (Usamos una que no exista para probar el log)
);