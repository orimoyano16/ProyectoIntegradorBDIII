-- Agrego tabla fecha_baja para poder dar de baja a los usuarios
alter table usuario add column fecha_baja timestamp default null;

-- Por defecto los usuarios tienen NULL en esta columna, si se dan de baja se cambia a la fecha.