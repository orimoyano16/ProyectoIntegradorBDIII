EXPLAIN (ANALYZE, VERBOSE)
SELECT * from usuario WHERE email = 'email120453@gmail.com';

-- Dalibo
EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON)
SELECT * from usuario WHERE email = 'email120453@gmail.com';
