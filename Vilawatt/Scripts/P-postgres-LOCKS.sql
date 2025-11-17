-- Locks granted
select relation::regclass, * from pg_locks where not granted;
 
-- Current queries
select pid, state, usename, query, query_start 
from pg_stat_activity 	
where pid in (
  select pid from pg_locks l 
  join pg_class t on l.relation = t.oid 
  and t.relkind = 'r' 
--  where t.relname = 'search_hit'
);
   
  SELECT a.datname,
         a.pid,
         l.relation::regclass,
         a.query,
         l.transactionid,
         l.mode,
         l.GRANTED,
         a.usename,
         a.query_start,
         age(now(), a.query_start) AS "age"
FROM pg_stat_activity a
JOIN pg_locks l ON l.pid = a.pid
WHERE datname ~* 'vw'
ORDER BY MODE DESC, a.query_start;

SELECT pg_cancel_backend(9707);
SELECT pg_terminate_backend(9707);
