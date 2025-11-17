SELECT * FROM record_custom_field_values rcfv LIMIT 5;


SELECT * FROM users u WHERE id=24;

SELECT id FROM users u WHERE username='jaume.cat';

SELECT ucf.internal_name, ucf.TYPE, ucf.id, COALESCE(COALESCE(string_value,''||integer_value),''||date_value) AS valor, ucfv.*
  FROM user_custom_field_values ucfv
	   LEFT OUTER JOIN user_custom_fields ucf ON ucfv.field_id=ucf.id
 WHERE ucfv.owner_id = 24
   AND ucf.id IN (18,19,20,23,21,77,78,79,80,81,82,54,56,57)
 ORDER BY ucf.id;

SELECT lo_id--, encode(lo_get(lo_id), 'base64') 
  FROM stored_files
 WHERE user_value_id IN (174,176) 
ORDER BY id LIMIT 200;

SELECT 
    t.table_schema,
    t.table_name,
    c.column_name,
    c.data_type
FROM 
    information_schema.tables t
    JOIN information_schema.columns c ON t.table_name = c.table_name
WHERE 
    t.table_schema NOT IN ('pg_catalog', 'information_schema')
    AND (
        c.data_type LIKE '%oid%' 
        OR c.data_type = 'integer' 
        OR c.data_type = 'bigint'
    )
    ORDER BY t.table_schema,
    t.table_name,
    c.column_name;