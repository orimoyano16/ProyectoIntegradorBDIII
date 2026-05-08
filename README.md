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


