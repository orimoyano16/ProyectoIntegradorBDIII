
-- Analizamos sin indexacion
EXPLAIN (ANALYZE, VERBOSE)
SELECT * from usuario WHERE email = 'email120453@gmail.com';

-- Creamos el indice 
create index idx_usuario_email on usuario using hash(email);

-- analizamos nuevamente los tiempos y costos de la busqueda
EXPLAIN (ANALYZE, VERBOSE)
SELECT * from usuario WHERE email = 'email120453@gmail.com';