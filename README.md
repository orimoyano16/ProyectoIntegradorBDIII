# ***Proyecto Integrador BDIII***
----------------------------------------------------------------------------------------------
## _Documentación técnica_
## `Identificación del proyecto`

| Nombre del proyecto | Sistema de Asistencias                                             |
|---------------------|--------------------------------------------------------------------|
| Descripción         | Es una base de datos para un sistema de asistencia institucional   |
| Integrantes         | Acuña Roman, Marranti Santiago, Moyano Oriana, Santillan Ariadna   |

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
|B-TREE|PK,FK,dni,rol,fecha,alumno_id,comison,id |Por defecto. Ideal para igualdad, rango y ordenamiento. Soporta <, >, BETWEEN, ORDER BY|
|Hash  |email, dni (solo busquedas exactas)|Muy rapido para igualdad exacta (=). No soporta rangos ni ordenamiento|
|GIN   |observacion (texto completo), nombre y apellido|Busqueda de palabras clave en textos. Usa to_tsvector() para español|
|GIST  |ubicacion GPS, rangos de fechas superpuestos|Datos espaciales/geometricos. Verificar geolocalizacion o solapamiento de horarios|

----------------------------------------------------------------------------------------------------------------------------------------------

## `Análisis de Performance`
#### _Consulta sin optimizar_ 


-------------------------------------------------------------------------------------------------------------------------------------------------

#### _Consulta Optimizada_


--------------------------------------------------------------------------------------------------------------------------------------------------

#### _Monitoreo de Consultas_ 
##### Top 5 Consultas con pg_stat_statement:
---------------------------------------------------------------------------------------------
##1. Consultas por mayor tiempo total de ejecución

#Identifica qué consultas consumen más recursos del sistema en total
```sql
SELECT 
    query,
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_time_ms,
    ROUND(mean_exec_time::numeric, 2) AS avg_time_ms,
    rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;
```
--------------------------------------------------------------------------------------------
##2.  Consultas por mayor tiempo promedio por ejecución

#Útil cuando los usuarios reportan lentitud en operaciones puntuales


```sql
SELECT 
    query,
    calls,
    ROUND(mean_exec_time::numeric, 2) AS avg_time_ms,
    ROUND(total_exec_time::numeric, 2) AS total_time_ms,
    rows
FROM pg_stat_statements
WHERE calls > 1
ORDER BY mean_exec_time DESC
LIMIT 5;
```
-------------------------------------------------------------------------------------------
##3.  Consultas por mayor uso de I/O (lectura de disco)

#Identifica consultas que no aprovechan caché y leen desde disco


```sql
SELECT 
    query,
    calls,
    shared_blks_read AS disk_blocks_read,
    shared_blks_hit AS cache_hits,
    ROUND(
        100 * shared_blks_hit::numeric /
        NULLIF(shared_blks_hit + shared_blks_read, 0),
        2
    ) AS cache_hit_ratio
FROM pg_stat_statements
WHERE shared_blks_read > 0
ORDER BY shared_blks_read DESC
LIMIT 5;
```
-------------------------------------------------------------------------------------------
##4. Consultas por mayor generación de WAL (escritura)

#Identifica operaciones que generan mucha carga de escritura en el servidor


```sql
SELECT 
    query,
    calls,
    wal_records,
    ROUND(wal_bytes::numeric, 2) AS wal_bytes,
    ROUND(
        wal_bytes::numeric / NULLIF(calls, 0),
        2
    ) AS wal_per_call
FROM pg_stat_statements
WHERE wal_records > 0
ORDER BY wal_bytes DESC
LIMIT 5;
```
------------------------------------------------------------------------------------------
##5. Consultas por mayor tiempo de planificación

#Identifica consultas complejas donde el planificador tarda mucho


```sql
SELECT 
    query,
    calls,
    plans,
    ROUND(total_plan_time::numeric, 2) AS total_plan_time_ms,
    ROUND(mean_plan_time::numeric, 2) AS avg_plan_time_ms,
    ROUND(total_exec_time::numeric, 2) AS total_exec_time_ms
FROM pg_stat_statements
WHERE plans > 0
  AND total_plan_time > 0
ORDER BY total_plan_time DESC
LIMIT 5;
```
---------------------------------------------------------------------------------------------------------------------------------------------------

## `SQL Avanzado: Lógica de Negocio`
|Herramienta    | Nombre | Explicacion de su uso|
|---------------|--------|----------------------|
|Window Function|        |                      |
|CTE            |        |                      |


----------------------------------------------------------------------------------------------------------------------------------------------------


