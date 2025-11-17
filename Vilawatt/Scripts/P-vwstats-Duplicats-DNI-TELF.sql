SELECT * FROM cyclos_users cu LIMIT 10;

-- Duplicats per DNI
WITH clh2 AS
(SELECT user_id, max(date_time) AS date_time FROM cyclos_login_history_logs clh GROUP BY user_id )
SELECT
	mcu.idcyclos,
	mcu.username,
	mcu.dni,
	mcu.telef,
	mcu.grup,
	mbp.given,
	mbp.bought,
	mcu.email,
	mcu.name || ' (' || mcu.id || ')',
	mcu.creation_date,
	clh2.date_time AS last_login
FROM
	mv_cyclos_users mcu
	LEFT OUTER JOIN mv_bonusers_prod mbp ON (mbp.id = mcu.id)
	LEFT OUTER JOIN clh2 ON (clh2.user_id = mcu.id)
WHERE
	mcu.dni IN (
		SELECT
			dni
		FROM
			mv_cyclos_users mcu2 
			WHERE status ='ACTIVE'
		GROUP BY
			dni
		HAVING
			count(*)>1
	)
	AND mcu.status='ACTIVE'
ORDER BY
	mcu.dni,
	last_login DESC,
	mcu.name
	
-- Duplicats per telèfon	
WITH clh2 AS
(SELECT user_id, max(date_time) AS date_time FROM cyclos_login_history_logs clh GROUP BY user_id )
SELECT
	mcu.idcyclos,
	mcu.username,
	mcu.dni,
	mcu.telef,
	mcu.grup,
	mbp.given,
	mbp.bought,
	mcu.email,
--	mcu.id,
	mcu.name,
	mcu.creation_date,
	clh2.date_time AS last_login
FROM
	mv_cyclos_users mcu
	LEFT OUTER JOIN mv_bonusers_prod mbp ON (mbp.id = mcu.id)
	LEFT OUTER JOIN clh2 ON (clh2.user_id = mcu.id)
WHERE
	mcu.telef IN (
		SELECT
			telef
		FROM
			mv_cyclos_users mcu2 
			WHERE status ='ACTIVE'
		GROUP BY
			telef
		HAVING
			count(*)>1
	)
	AND mcu.status='ACTIVE'
ORDER BY
	mcu.telef,
	mcu.creation_date,
	mcu.name

-- Sense 2n cognom	
SELECT
	mcu.idcyclos, mcu."name" AS fullname, ucfv1.string_value AS cog1, ucfv2.string_value AS cog2, mcu.dni, mcu.email, mcu. telef, mcu.status 
FROM
	mv_cyclos_users mcu
	LEFT OUTER JOIN cyclos_user_custom_field_values ucfv1 ON (ucfv1.owner_id =mcu.id AND ucfv1.field_id =19)
	LEFT OUTER JOIN cyclos_user_custom_field_values ucfv2 ON (ucfv2.owner_id =mcu.id AND ucfv2.field_id =20)
WHERE 
	mcu.grup ='Particulars' AND 
	ucfv2.string_value IS NULL 
ORDER BY status, dni;

-- Sense titular real
SELECT
	mcu.idcyclos, mcu."name" AS fullname, 
	ucfv1.string_value AS tit1, ucfv2.string_value AS tit2, ucfv3.string_value AS tit3, 
	ucfv4.string_value AS dni, ucfv5.string_value AS nif, mcu.email, mcu. telef, mcu.status , mcu.grup 
FROM
	mv_cyclos_users mcu
	LEFT OUTER JOIN cyclos_user_custom_field_values ucfv1 ON (ucfv1.owner_id =mcu.id AND ucfv1.field_id =37)
	LEFT OUTER JOIN cyclos_user_custom_field_values ucfv2 ON (ucfv2.owner_id =mcu.id AND ucfv2.field_id =38)
	LEFT OUTER JOIN cyclos_user_custom_field_values ucfv3 ON (ucfv3.owner_id =mcu.id AND ucfv3.field_id =39)
	LEFT OUTER JOIN cyclos_user_custom_field_values ucfv4 ON (ucfv4.owner_id =mcu.id AND ucfv4.field_id =42)
	LEFT OUTER JOIN cyclos_user_custom_field_values ucfv5 ON (ucfv5.owner_id =mcu.id AND ucfv5.field_id =44)
WHERE 
	mcu.grup ='Empreses' 
AND status IN ('ACTIVE', 'PENDING')
--AND ucfv2.string_value IS NULL 
ORDER BY status, nif;


SELECT * FROM mv_cyclos_users mcu WHERE name~* 'leben'

SELECT owner_id, ucfv1.string_value, ucfv1.field_id,  ucfv1.linked_entity_id
  FROM cyclos_user_custom_field_values ucfv1 
 WHERE ucfv1.owner_id = iddecypher(-9105007265693181272) ORDER BY field_id 
 	