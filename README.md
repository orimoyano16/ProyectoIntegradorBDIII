# ***Proyecto Integrador BDIII***
----------------------------------------------------------------------------------------------
# PARTE 1
## _Documentación técnica_
## `Identificación del proyecto`

| Nombre del proyecto | Sistema de Asistencias                                             |
|---------------------|--------------------------------------------------------------------|
| Descripción         | Es una base de datos para un sistema de asistencia institucional   |
| Integrantes         | Acuña Roman, Marranti Santiago, Moyano Oriana, Santillan Ariadna   |
| Objetivo            |Construir una base sólida y optimizada bajo el paradigma relacional, aplicando técnicas de indexación avanzada y análisis de performance|

### `Problematica que resuelve`

* Perdida de tiempo administrativo: Los docentes dedican parte valiosa de la hora de catedra a pasar lista manualmente, lo que les lleva entre 10 y 15 minutos.
* Actualmente,  algunas instituciones educativas todavía dependen de métodos manuales (Planillas de papel,excel aislados, etc) lo que genera ineficiencia.
* Por parte de los alumnos, a veces resulta difícil consultar el estado de inasistencias de manera inmediata.
------------------------------------------------------------------------------------------------
## `Modelado de datos`
### _Diagrama Entidad Relación (DER)_
_link_: https://lucid.app/lucidchart/c6cb8a3d-38b0-45f1-9f97-e9c164d87dbd/edit?view_items=W3UUUt0DR6h.&page=0_0&invitationId=inv_df0f3482-dee0-4a78-9aaf-9dd1dfcf604d

<img width="4205" height="2948" alt="Diagrama en blanco (1)" src="https://github.com/user-attachments/assets/a9fa1cd1-1c67-4ec5-90cf-fd6feee957ba" />


------------------------------------------------------------------------------------------------------------------------------------------

#### _Diagrama generado con DBeaver_

<img width="691" height="515" alt="image" src="https://github.com/user-attachments/assets/afd30231-78dc-4a60-9e2a-c49486b63049" />

## `Estrategia de Indexación y Optimización`
|Index | ¿Donde lo usamos?| Justificacion de uso |
|------|------------------|----------------------|
|B-TREE|Dentro de la tabla usuario, lo usamos con dni, y carrera id y dentro de la tabla asistencia, lo usamos en fecha |En la tabla usuario para buscar rapido a los usuarios por su DNI y en la tabla asistencia para agilizar la busqueda por fecha|
|Hash  |Dentro de la tabla usuarios, lo usamos en e-mail|Lo usamos en e-mail para poder buscar en la columna una igualdad con e-mail que se solicite|
|GIN   |Dentro de la tabla asistencia, lo usamos en la columna observacion |En observacion, los usuarios deben justificar su falta, entonces esto nos ayuda en la busqueda de texto (full text search)|
|GIST  |No lo usamos |No tenemos atributos que requieran una implentacion de GIST|

----------------------------------------------------------------------------------------------------------------------------------------------
## `Análisis de Performance`
#### _Consulta sin optimizar_ 

<img width="1116" height="649" alt="image" src="https://github.com/user-attachments/assets/5851b37f-3ba3-4f8d-819f-45dfa30dc023" />


-------------------------------------------------------------------------------------------------------------------------------------------------

#### _Consulta Optimizada_

<img width="1111" height="648" alt="image" src="https://github.com/user-attachments/assets/a03ec42b-81a6-4ad1-ac2c-c9a575209b39" />


--------------------------------------------------------------------------------------------------------------------------------------------------

## Dalibo - Sequential Scans VS Index Scans

### _Sequential Scan_

<img width="1365" height="576" alt="image" src="https://github.com/user-attachments/assets/610776aa-9cd5-45ab-89ab-ab4d79630a45" />

### _Index Scan_

<img width="1365" height="579" alt="image" src="https://github.com/user-attachments/assets/f4339eab-5abf-493a-9704-87bb2359994c" />

----------------------------------------------------------------------------------------------------------------------------------------------

#### _Monitoreo de Consultas_ 

##### Top 5 Consultas con pg_stat_statement:

| Top | Consulta | Explicación |
|------|-----------|--------------|
|1|Consultas más lentas|Identifica las queries con mayor tiempo de ejecución|
|2|Consultas más ejecutadas|Muestra las consultas realizadas con mayor frecuencia|
|3|Consultas con más I/O|Analiza las consultas que más leen datos de disco|
|4|Consultas con más WAL|Detecta las consultas que más escritura generan en WAL|
|5|Consultas con mayor planificación|Mide el tiempo usado por el optimizador de consultas|

##### 1. _Consultas más lentas_
```sql
SELECT query, total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;
```
* SELECT → elige qué datos querés ver,query (la consulta SQL) y total_exec_time (tiempo total)

* FROM pg_stat_statements → de dónde saca los datos

* ORDER BY total_exec_time DESC → ordena de mayor a menor

* LIMIT 5 → limita el resultado

##### 2. _Consultas más ejecutadas_
```sql
SELECT query, calls
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 5;
```
* SELECT → muestra la consulta y cuántas veces se ejecutó

* FROM → toma los datos de PostgreSQL

* ORDER BY calls DESC → ordena por más ejecuciones

* LIMIT 5 → limita el resultado

##### 3. _Consultas con más I/O_
```sql   
SELECT query, shared_blks_read
FROM pg_stat_statements
ORDER BY shared_blks_read DESC
LIMIT 5;
```
* SELECT → muestra consulta y lecturas de disco

* FROM → toma datos del sistema

* ORDER BY shared_blks_read DESC → ordena por más lectura de disco

* LIMIT 5 → limita el resultado

##### 4. _Consultas con más WAL_
```sql
SELECT query, wal_bytes
FROM pg_stat_statements
ORDER BY wal_bytes DESC
LIMIT 5;
```
* SELECT → muestra consulta y escritura en WAL

* FROM → estadísticas del sistema

* ORDER BY wal_bytes DESC → ordena por más escritura

* LIMIT 5 → limita el resultado 

##### 5. _Consultas con más planificación_
```sql
SELECT query, total_plan_time
FROM pg_stat_statements
ORDER BY total_plan_time DESC
LIMIT 5;
```
* SELECT→ muestra consulta y tiempo de planificación

* FROM → toma datos del sistema

* ORDER BY total_plan_time DESC → ordena por las más costosas de planificar

* LIMIT 5 → limita el resultado   

---------------------------------------------------------------------------------------------------------------------------------------------------

## `SQL Avanzado: Lógica de Negocio`
|Herramienta    | Nombre | Explicacion de su uso|
|---------------|--------|----------------------|
|CTE            |WITH ... AS|Usamos una CTE para dar orden y preparar los datos para calcular el porcentaje de asistencias.|
|Window Function|ROW_NUMBER(), RANK(), LAG(), LEAD(), AVG() OVER()| Usamos una Window Function para evitar el costo de procesamiento de la subconsulta repetitiva, podemos ver la asistencia por comision, numero de asistencia por alumno, mejor asistencia, ausencia consecutiva, etc|



----------------------------------------------------------------------------------------------------------------------------------------------------

# PARTE 2

## `A. Abstracción y Lógica Procesal`

Implementación en `Scripts SQL/Parte A - Logica Procedural.sql`. Las pruebas están en `Parte A - Pruebas.sql`.

### Función (FUNCTION)

Son rutinas que **devuelven un valor** y encapsulan lógica reutilizable sin modificar datos por sí solas.

| Función | Volatilidad | Qué hace |
|---------|-------------|----------|
| `fn_calcular_porcentaje_asistencia(alumno_id, comision_id)` | **STABLE** | Cuenta las asistencias del alumno en esa comisión y devuelve el porcentaje de estados `PRESENTE`. Si no hay registros, devuelve `0`. Valida que el alumno y la comisión existan. |
| `fn_clasificar_nivel_asistencia(porcentaje)` | **IMMUTABLE** | Traduce un número a una etiqueta: `regular` (≥ 75 %), `en_riesgo` (≥ 50 %), `critico` (menor a 50 %) o `sin_datos` si el valor es nulo. No consulta tablas, solo el parámetro. |

**STABLE** indica que la función lee la base pero no la altera; PostgreSQL puede optimizarla en consultas repetidas. **IMMUTABLE** indica que el resultado depende solo del argumento, lo que permite usarla en índices o expresiones sin riesgo de lecturas inconsistentes.

Ejemplo de uso encadenado:

```sql
SELECT
    fn_calcular_porcentaje_asistencia(1, 1) AS porcentaje,
    fn_clasificar_nivel_asistencia(
        fn_calcular_porcentaje_asistencia(1, 1)
    ) AS nivel;
```

### Procedimiento almacenado (PROCEDURE)

A diferencia de una función, un procedimiento **puede ejecutar acciones** (INSERT, UPDATE, etc.) y devolver valores por parámetros `OUT`.

**`sp_inscribir_alumno_comision(alumno_id, comision_id, OUT inscripcion_id)`** inscribe un alumno en una comisión aplicando reglas de negocio:

1. Verifica que existan el alumno, la comisión y su materia.
2. Comprueba que la carrera del alumno coincida con la de la materia.
3. Impide inscripciones duplicadas en la misma comisión.
4. Inserta el registro en `inscripcion` y devuelve el `inscripcion_id` generado.

Si alguna regla falla, lanza una excepción y no guarda nada. Se invoca con `CALL`:

```sql
CALL sp_inscribir_alumno_comision(1, 2, v_id);
```

### Robustez de tipos

En PL/pgSQL usamos tipos **derivados del esquema** para que el código no quede atado a tamaños fijos (`INT`, `VARCHAR`, etc.) que podrían desincronizarse si cambia una columna:

| Sintaxis | Uso en el proyecto |
|----------|-------------------|
| `columna%TYPE` | Variables como `v_alumno_id usuario.usuario_id%TYPE` heredan el tipo exacto de la columna. |
| `tabla%ROWTYPE` | Registros como `v_alumno usuario%ROWTYPE` guardan una fila completa con todas sus columnas tipadas. |

Si en el futuro se modifica el tipo de `usuario_id` o se agrega una columna a `usuario`, las variables y el `SELECT * INTO` siguen siendo válidos sin reescribir el procedimiento.

### Abstracción (permisos)

El rol `app_asistencias` solo tiene permiso de **ejecutar** las funciones y el procedimiento; no puede leer ni escribir las tablas directamente (`REVOKE` sobre tablas, `GRANT EXECUTE` sobre la lógica procedural). La aplicación accede a los datos a través de esta capa, no con SQL directo sobre las tablas.

---------------------------------------------------------------------------------------------------------------------------------------------------

## `B. Gestión Avanzada de Transacciones`

Implementación en `Scripts SQL/Commit y Rollback.sql`.

### Atomicidad

Una transacción agrupa varias operaciones en una unidad indivisible: o se confirman todas (`COMMIT`) o ninguna (`ROLLBACK`). En el script se inserta un usuario y luego se intenta una inscripción inválida; con `ROLLBACK TO SAVEPOINT` se deshace solo la inscripción fallida y se mantiene el alta del usuario. Al final, `COMMIT` confirma lo que quedó válido.

El procedimiento `registrar_usuario` aplica el mismo concepto: el alta del alumno es la operación crítica; si la inscripción falla, un bloque `EXCEPTION` revierte solo esa parte y registra el error, pero el usuario ya creado se confirma con `COMMIT`.

### Manejo de errores parciales

`SAVEPOINT` y bloques `BEGIN … EXCEPTION … END` permiten **fallar en una parte sin perder todo**. Si la comisión no existe, la inscripción se cancela pero el usuario permanece. El error queda registrado en `audit_logs` para trazabilidad.

---

## `C. Capa de Auditoría y Forense de Datos`

Implementación en `Scripts SQL/Auditlogs.sql`. La tabla `audit_logs` (definida en `Creacion de tablas.sql`) guarda fecha, usuario, código y mensaje de cada incidente.

### Tabla de logs

| Columna | Uso |
|---------|-----|
| `fecha` | Momento del evento |
| `usuario` | Usuario de BD que ejecutó la operación |
| `codigo_error` | Código SQLSTATE del error (o código propio) |
| `mensaje_error` | Descripción legible del fallo |

### Captura de excepciones

El procedimiento `registrar_inscripcion` intenta insertar en `inscripcion`. Si falla (ID inexistente, llave foránea, duplicado, etc.), captura el error con `GET STACKED DIAGNOSTICS` y lo persiste en `audit_logs` sin detener la sesión.

- Mensaje de error al ejecutar con IDs inválidos:

<img width="923" height="75" alt="image" src="https://github.com/user-attachments/assets/71776f6e-ebd4-4b9a-80f8-ef22af33d961" />

- Registro del error en `audit_logs`:

<img width="923" height="606" alt="image" src="https://github.com/user-attachments/assets/b1f49eb1-e176-4c73-b345-8ef70b9dccf3" />

---

## `D. Seguridad y Blindaje (Hardening)`

Implementación en `Scripts SQL/Parte D - Seguridad y Blindaje.sql`.

### Definidor vs invocador

| Modo | Dónde lo usamos | Por qué |
|------|-----------------|---------|
| **SECURITY INVOKER** (por defecto) | Funciones de cálculo (`fn_calcular_porcentaje_asistencia`, `fn_clasificar_nivel_asistencia`) | Solo leen datos; no necesitan privilegios elevados. |
| **SECURITY DEFINER** | `sp_inscribir_alumno_comision` | Ejecuta con permisos del dueño del procedimiento, permitiendo que roles limitados (`app_asistencias`) inscriban alumnos sin acceso directo a las tablas. |

### Protección contra inyección

El procedimiento usa `SET search_path = public` para fijar el esquema y evitar que un atacante redirija objetos a tablas maliciosas. Los parámetros se pasan tipados (`INT`), no concatenados en SQL dinámico, lo que impide inyección por entrada de usuario.

Principio aplicado: **privilegio mínimo** — la app solo ejecuta procedimientos autorizados, no consulta tablas directamente.

<img width="678" height="247" alt="Captura de pantalla 2026-06-01 182418" src="https://github.com/user-attachments/assets/650ee818-006d-436e-ad93-0d70f1466c08" />

---

## `E. Automatización con Triggers`

Implementación en `Scripts SQL/triggers.sql`.

### Validación y auditoría automática

La función `fn_auditar_cambio_asistencia` se dispara **después** de cada `UPDATE` en `asistencia`. Si cambia el campo `estado`, registra en `audit_logs` el valor anterior (`OLD`) y el nuevo (`NEW`) usando `format()`, sin intervención manual.

El trigger `trg_auditoria_asistencia` ejecuta esa función en cada fila modificada. Si el propio INSERT en `audit_logs` falla, un bloque `EXCEPTION` captura el error del sistema y lo vuelve a registrar.

Ejemplo: al cambiar una asistencia de `Ausente` a `Presente`, el log se genera automáticamente:

<img width="937" height="537" alt="image" src="https://github.com/user-attachments/assets/c67e2340-152a-403b-828f-598aac3644e9" />

----------------------------------------------------------------------------------------------------------------------------------------------------

# PARTE 3

## `Integración de Caché con Redis (Persistencia Políglota)`

Implementación del patrón **Cache-Aside** con PostgreSQL + Redis.

| Recurso | Ubicación |
|---------|-----------|
| Documentación y checklist | [`Parte 3 - Redis/README.md`](Parte%203%20-%20Redis/README.md) |
| API backend | `Parte 3 - Redis/backend/` |
| Docker (PostgreSQL + Redis) | `Parte 3 - Redis/docker-compose.yml` |

**Endpoints cacheados:**

- `GET /api/alumnos/:id/asistencia/:comisionId` → clave `asistencia:{id}:{comisionId}` (TTL 120 s)
- `GET /api/usuarios/dni/:dni` → clave `users:dni:{dni}` (TTL 300 s)

### Qué se hizo

- API con patrón **Cache-Aside** (Redis + PostgreSQL).
- Docker, TTL, nomenclatura de claves y fallback implementados.
- Probado en navegador: PONG y Cache HIT.

### Capturas

| Prueba | Imagen |
|--------|--------|
| Endpoints de la API | ![API](Parte%203%20-%20Redis/imagenes/01-api-endpoints.png) |
| Redis PONG | ![PONG](Parte%203%20-%20Redis/imagenes/02-redis-pong.png) |
| Cache HIT | ![HIT](Parte%203%20-%20Redis/imagenes/03-cache-hit.png) |

Documentación completa: [`Parte 3 - Redis/README.md`](Parte%203%20-%20Redis/README.md)

