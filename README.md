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




---------------------------------------------------------------------------------------------------------------------------------------------------

## `SQL Avanzado: Lógica de Negocio`
|Herramienta    | Nombre | Explicacion de su uso|
|---------------|--------|----------------------|
|Window Function|        |                      |
|CTE            |        |                      |


----------------------------------------------------------------------------------------------------------------------------------------------------


