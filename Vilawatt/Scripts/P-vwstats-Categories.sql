-- Llista de categories
SELECT * FROM stats_categories sc ORDER BY id;

-- Quantitat de comerços per categoria
REFRESH MATERIALIZED VIEW mv_cyclos_users; -- Important !!!

SELECT count(*), scu.categ, sc.desc_ca, string_agg('"'||mcu."name"||'"', ', ')
  FROM mv_cyclos_users mcu 
  	   LEFT OUTER JOIN stats_categories_users scu ON (scu.userid=mcu.id)
  	   LEFT OUTER JOIN stats_categories sc ON (sc.id=scu.categ)
 WHERE grup IN ('Autònoms', 'Empreses') 
   AND mcu.status ='ACTIVE'
 GROUP BY scu.categ, sc.desc_ca
 ORDER BY categ NULLS FIRST;

-- Llista de comerços, categoria i quantitat de bons cobrats
 WITH mp AS (
 	SELECT payee_id, sum(v_redeem) AS suma
   	  FROM  mv_payments mp2 
   	  GROUP BY payee_id)
SELECT scu.categ, sc.desc_ca, count(*)
  FROM mv_cyclos_users mcu 
  	   LEFT OUTER JOIN stats_categories_users scu ON (scu.userid=mcu.id)
  	   LEFT OUTER JOIN stats_categories sc ON (sc.id=scu.categ)
  	   LEFT OUTER JOIN mp ON (iddecypher(mp.payee_id)=mcu.id)
 WHERE grup IN ('Autònoms', 'Empreses') 
   AND mcu.status ='ACTIVE'
 GROUP BY GROUPING SETS ((categ, desc_ca),())
 ORDER BY categ NULLS FIRST;

REFRESH MATERIALIZED VIEW mv_payments;

-- Llista de comerços, categoria i saldo cobrat en bons
 WITH mp AS (
 	SELECT payee_id, sum(v_redeem) AS suma
   	  FROM  mv_payments mp2 
   	  GROUP BY payee_id)
SELECT  scu.categ, sc.desc_ca, mcu.name, sum(suma) AS suma
  FROM mv_cyclos_users mcu 
  	   LEFT OUTER JOIN stats_categories_users scu ON (scu.userid=mcu.id)
  	   LEFT OUTER JOIN stats_categories sc ON (sc.id=scu.categ)
  	   LEFT OUTER JOIN mp ON (iddecypher(mp.payee_id)=mcu.id)
 WHERE grup IN ('Autònoms', 'Empreses') 
   AND mcu.status ='ACTIVE' AND suma > 0
 GROUP BY GROUPING SETS ((name, categ, desc_ca),(categ,desc_ca),())
-- ORDER BY categ, suma , name;

SELECT * FROM stats_categories sc ORDER BY id;

SELECT * FROM stats_categories_users;

INSERT INTO stats_categories_users VALUES (5349, 'COM15')

-- Llista de comerços, categoria i saldo cobrat en bons
WITH mp2 AS (
 WITH mp AS (
 	SELECT payee_id, sum(v_redeem) AS suma
   	  FROM  mv_payments mp2 
   	  GROUP BY payee_id)
SELECT mcu.id, mcu.name, scu.categ, sc.desc_ca, round(suma) AS suma, ucfv1.field_id, ucfv1.string_value
  FROM mv_cyclos_users mcu 
  	   LEFT OUTER JOIN stats_categories_users scu ON (scu.userid=mcu.id)
  	   LEFT OUTER JOIN stats_categories sc ON (sc.id=scu.categ)
  	   LEFT OUTER JOIN mp ON (iddecypher(mp.payee_id)=mcu.id)
  	   LEFT OUTER JOIN cyclos_user_custom_field_values ucfv1 ON (ucfv1.owner_id = mcu.id AND ucfv1.field_id IN (77, 78, 79, 80))
 WHERE grup IN ('Autònoms', 'Empreses')
   AND mcu.status ='ACTIVE'
 ORDER BY categ NULLS FIRST , suma DESC NULLS LAST, name, field_id)
SELECT id, name, categ, desc_ca, suma, string_agg(string_value,', ')
  FROM mp2
 GROUP BY id, name, categ, desc_ca, suma
 ORDER BY categ NULLS FIRST, suma DESC NULLS LAST, name;

					(SELECT owner_id
					  FROM cyclos_user_custom_field_values ucfv1 
				     WHERE ucfv1.owner_id = u.id
		 		       AND ucfv1.string_value ~* '08840'
				       AND ucfv1.field_id IN (77, 78, 79, 80))


-- Llista de categories amb total cobrat en bons
WITH mp AS (
    SELECT payee_id, sum(v_redeem) AS suma
    FROM mv_payments
    GROUP BY payee_id
), total_suma AS (
    SELECT sum(suma) AS total
    FROM mp
)
SELECT sc.desc_ca, 
       sum(suma) AS suma,
       -- Calculate the percentage
       round((sum(suma) / total_suma.total) * 100, 2) AS percentage
FROM mv_cyclos_users mcu 
LEFT OUTER JOIN stats_categories_users scu ON scu.userid = mcu.id
LEFT OUTER JOIN stats_categories sc ON sc.id = scu.categ
LEFT OUTER JOIN mp ON iddecypher(mp.payee_id) = mcu.id
CROSS JOIN total_suma
--WHERE mcu.grup IN ('Autònoms', 'Empreses') AND mcu.status = 'ACTIVE'
GROUP BY scu.categ, sc.desc_ca, total_suma.total
ORDER BY sum(suma) DESC NULLS LAST;


---------------------------------------------------------------
-- Obté categoria d'establiment segons taula Ubiquat
SELECT
	u.id, u.status,
	initcap(u."name") AS nom,
	lower(username) AS usuari,
	cfv.string_value AS classe,
	sc.desc_ca 
FROM
	cyclos_users u
	LEFT JOIN cyclos_user_custom_field_values cfv 	ON	cfv.owner_id = u.id
	LEFT JOIN cyclos_user_custom_fields cf 		ON	cf.id = cfv.field_id
	LEFT JOIN stats_categories sc 				ON  sc.id = cfv.string_value
WHERE
	u.network_id  = 2
	AND cf.internal_name = 'classificationCode'
ORDER BY
	status,nom,username;
