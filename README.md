# ***Proyecto Integrador BDIII***
----------------------------------------------------------------------------------------------
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
|B-TREE|PK,FK,dni,rol,fecha,alumno_id,comison,id |Por defecto. Ideal para igualdad, rango y ordenamiento. Soporta <, >, BETWEEN, ORDER BY|
|Hash  |email, dni (solo busquedas exactas)|Muy rapido para igualdad exacta (=). No soporta rangos ni ordenamiento|
|GIN   |observacion (texto completo), nombre y apellido|Busqueda de palabras clave en textos. Usa to_tsvector() para español|
|GIST  |ubicacion GPS, rangos de fechas superpuestos|Datos espaciales/geometricos. Verificar geolocalizacion o solapamiento de horarios|

----------------------------------------------------------------------------------------------------------------------------------------------
## `Análisis de Performance`
#### _Consulta sin optimizar_ 

<img width="1116" height="649" alt="image" src="https://github.com/user-attachments/assets/5851b37f-3ba3-4f8d-819f-45dfa30dc023" />


-------------------------------------------------------------------------------------------------------------------------------------------------

#### _Consulta Optimizada_

<img width="1111" height="648" alt="image" src="https://github.com/user-attachments/assets/a03ec42b-81a6-4ad1-ac2c-c9a575209b39" />


--------------------------------------------------------------------------------------------------------------------------------------------------

## Dalibo - Sequential Scans VS Index Scans

### Sequential Scan

<img width="1365" height="576" alt="image" src="https://github.com/user-attachments/assets/610776aa-9cd5-45ab-89ab-ab4d79630a45" />

### Index Scan

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

* LIMIT 5 → muestra solo las 5 más ejecutadas

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

* LIMIT 5 → top 5

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

* LIMIT 5 → top 5 

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

* LIMIT 5 → top 5   

---------------------------------------------------------------------------------------------------------------------------------------------------

## `SQL Avanzado: Lógica de Negocio`
|Herramienta    | Nombre | Explicacion de su uso|
|---------------|--------|----------------------|
|Window Function|ROW_NUMBER(), RANK(), LAG(), LEAD(), AVG() OVER()|Calcula valores a través de filas relacionadas sin agruparlas. Útil para: ranking de asistencia por alumno, detectar ausencias consecutivas (LAG), promedio móvil de asistencias, numerar inscripciones por alumno|
|CTE            |WITH ... AS|Crea tablas temporales durante la ejecución de la consulta. Mejora la legibilidad y permite: consultas recursivas (jerarquías), reutilizar el mismo subquery varias veces, dividir problemas complejos en pasos simples (ej. primero calcular asistencias, luego filtrar ausencias >30%)|


----------------------------------------------------------------------------------------------------------------------------------------------------


