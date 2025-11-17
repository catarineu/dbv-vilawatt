-- Grant permission to read any large object
GRANT SELECT ON pg_largeobject TO vilawatt_cyclos_ro;

SELECT *
  FROM stored_files
 WHERE user_value_id IN (174,176) 
ORDER BY id LIMIT 200;

SELECT encode(my_lobject_reader(138312), 'base64');

SELECT * FROM users WHERE username='jaume.cat';

SELECT ucf.internal_name, ucf.TYPE, ucf.id, COALESCE(COALESCE(string_value,''||integer_value),''||date_value) AS valor, *
  FROM user_custom_field_values ucfv
	   LEFT OUTER JOIN user_custom_fields ucf ON ucfv.field_id=ucf.id
 WHERE ucfv.owner_id = 24
   AND ucf.id IN (18,19,20,23,21,77,78,79,80,81,82,54)
 ORDER BY ucf.id;

WITH files_ids AS (
	SELECT field_id, id FROM user_custom_field_values WHERE owner_id = 24 AND field_id IN (56,57)
)
SELECT files_ids.field_id, content_type, encode(my_lobject_reader(lo_id), 'base64') AS file_b64
  FROM files_ids
	   LEFT OUTER JOIN stored_files ON user_value_id=files_ids.id


      SELECT * FROM users WHERE username='jaume.cat';
  