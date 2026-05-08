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

<img width="1365" height="721" alt="image" src="https://github.com/user-attachments/assets/bfc9e87b-ec02-473e-9535-a43f52f2dc60" />

-------------------------------------------------------------------------------------------------------------------------------------------------

#### _Consulta Optimizada_
| Tipo | Consulta | Explicación |
|------|-----------|--------------|

<img width="1365" height="767" alt="image" src="https://github.com/user-attachments/assets/3184fcd2-b228-4dfe-8106-f5ec0fcfe3a4" />


--------------------------------------------------------------------------------------------------------------------------------------------------

#### _Monitoreo de Consultas_ 
##### Top 5 Consultas con pg_stat_statement:

| Top | Consulta | Explicación |
|------|-----------|--------------|
|1|Consultas más lentas|Identifica las queries con mayor tiempo de ejecución|
|2|Consultas más ejecutadas|Muestra las consultas realizadas con mayor frecuencia|
|3|Consultas con más I/O|Analiza las consultas que más leen datos de disco|
|4|Consultas con más WAL|Detecta las consultas que más escritura generan en WAL|
|5|Consultas con mayor planificación|Mide el tiempo usado por el optimizador de consultas|

1. Consultas más lentas
```sql
SELECT query, total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;
```
SELECT → elige qué datos querés ver,query (la consulta SQL) y total_exec_time (tiempo total)

FROM pg_stat_statements → de dónde saca los datos

ORDER BY total_exec_time DESC → ordena de mayor a menor

LIMIT 5 → limita el resultado

2. Consultas más ejecutadas
```sql
SELECT query, calls
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 5;
```
SELECT → muestra la consulta y cuántas veces se ejecutó

FROM → toma los datos de PostgreSQL

ORDER BY calls DESC → ordena por más ejecuciones

LIMIT 5 → muestra solo las 5 más ejecutadas

3. Consultas con más I/O
```sql   
SELECT query, shared_blks_read
FROM pg_stat_statements
ORDER BY shared_blks_read DESC
LIMIT 5;
```
SELECT → muestra consulta y lecturas de disco

FROM → toma datos del sistema

ORDER BY shared_blks_read DESC → ordena por más lectura de disco

LIMIT 5 → top 5

4. Consultas con más WAL
```sql
SELECT query, wal_bytes
FROM pg_stat_statements
ORDER BY wal_bytes DESC
LIMIT 5;
```
SELECT → muestra consulta y escritura en WAL

FROM → estadísticas del sistema

ORDER BY wal_bytes DESC → ordena por más escritura

LIMIT 5 → top 5 

5. Consultas con más planificación
```sql
SELECT query, total_plan_time
FROM pg_stat_statements
ORDER BY total_plan_time DESC
LIMIT 5;
```
SELECT→ muestra consulta y tiempo de planificación

FROM → toma datos del sistema

ORDER BY total_plan_time DESC → ordena por las más costosas de planificar

LIMIT 5 → top 5   

---------------------------------------------------------------------------------------------------------------------------------------------------

## `SQL Avanzado: Lógica de Negocio`
|Herramienta    | Nombre | Explicacion de su uso|
|---------------|--------|----------------------|
|Window Function|ROW_NUMBER(), RANK(), LAG(), LEAD(), AVG() OVER()|Calcula valores a través de filas relacionadas sin agruparlas. Útil para: ranking de asistencia por alumno, detectar ausencias consecutivas (LAG), promedio móvil de asistencias, numerar inscripciones por alumno|
|CTE            |WITH ... AS|Crea tablas temporales durante la ejecución de la consulta. Mejora la legibilidad y permite: consultas recursivas (jerarquías), reutilizar el mismo subquery varias veces, dividir problemas complejos en pasos simples (ej. primero calcular asistencias, luego filtrar ausencias >30%)|


----------------------------------------------------------------------------------------------------------------------------------------------------


