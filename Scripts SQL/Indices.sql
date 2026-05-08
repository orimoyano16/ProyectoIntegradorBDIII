-- Creamos el indice 
create index idx_usuario_email on usuario using hash(email);
CREATE INDEX idx_usuario_apellido ON usuario USING btree (dni); --buscamos a los usuarios por su dni
CREATE INDEX idx_usuario_carrera ON usuario USING btree (carrera_id); -- buscamos tambien usuarios por carrera

CREATE INDEX idx_asistencia_fecha ON asistencia USING btree (fecha); -- buscamos la asistencia por fecha

create index idx_asistencia_observacion on asistencia using GIN(to_tsvector('spanish', observacion)); -- buscamos texto relevante por full text search.