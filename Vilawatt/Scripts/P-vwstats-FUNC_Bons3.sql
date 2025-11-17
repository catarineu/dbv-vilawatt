INSERT INTO tmp_delta	-- api_voucher_campaign_custom_assignment_delta
		   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
		   (
WITH prev AS (SELECT iddecypher(user_id) AS uid, sum(quantity) AS quantity
					  FROM api_voucher_campaign_custom_assignment 
					 WHERE campaign_id = 2
					   AND quota_id in (1,2)     -- Quota GENERAL (bons 1,2,3)
					   AND quantity > 0
					   GROUP BY user_id)
SELECT 'BW2022 1-2-3', GREATEST(0,3-COALESCE(prev.quantity,0)::int) AS quant, 'Bons 1-2-3: Per domicili a Viladecans' AS descr, 
		           now(), idcypher(u.id), 2, 1, FALSE
			FROM
				cyclos_users u
				LEFT OUTER JOIN prev ON (prev.uid=u.id)
			WHERE
				u.network_id = 2
				AND u.id IN (
					-- Viuen a VLD
					(SELECT owner_id
					  FROM cyclos_user_custom_field_values ucfv1 
				     WHERE ucfv1.owner_id = u.id
		 		       AND ucfv1.string_value ~* '08840'
				       AND ucfv1.field_id IN (77, 78, 79, 80))
				    UNION 
					-- Treballen a VLD
				    (SELECT id FROM tmp_white_workers))
				AND u.id NOT IN (SELECT uid FROM prev WHERE quantity=3)
		        AND u.status = 'ACTIVE')
		        
		        
--		        AND u.name ~* 'silvia r'
		        ORDER BY name
		        
-- Mostra DELTAS de darrera setmana
SELECT	mcu.id, mcu.name, avccad.*
FROM	api_voucher_campaign_custom_assignment_delta avccad
		LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.idcyclos=avccad.user_id)
WHERE hidden IS FALSE  AND
      "timestamp" >= now()-'1 week'::interval
ORDER BY "timestamp" DESC;

SELECT * FROM api_voucher_campaign_custom_assignment avcca WHERE user_id =idcypher(1576);
SELECT * FROM cyclos_users cu WHERE "name" ~* 'lázaro' ORDER BY name;
SELECT idcypher(2732);

SELECT owner_id, ucfv1.field_id, ucfv1.string_value
  FROM cyclos_user_custom_field_values ucfv1 
 WHERE ucfv1.owner_id = 1576
ORDER BY ucfv1.field_id;
--   AND ucfv1.field_id IN (77, 78, 79, 80)

DROP FUNCTION vw_b1_cercanom(character varying) ;
SELECT * FROM vw_b1_cercanom('Catarineu');

-- Cerca actual
SELECT u.id, u.name, 'BW2022 1-2-3', 3, 'Bons 1-2-3: Per domicili a Viladecans', 
       now(), idcypher(u.id), 2, 1, FALSE
FROM
	cyclos_users u
WHERE
	u.network_id = 2
	AND u.id IN (
		-- Viuen a VLD
		(SELECT owner_id
		  FROM cyclos_user_custom_field_values ucfv1 
	     WHERE ucfv1.owner_id = u.id
	       AND ucfv1.string_value ~* '08840'
	       AND ucfv1.field_id IN (77, 78, 79, 80))
	    UNION 
		-- Treballen a VLD
	    (SELECT id FROM tmp_white_workers))
	AND u.id NOT IN (
		-- Ja se li ha assignat algun bo inicial
		SELECT iddecypher(user_id)
		  FROM api_voucher_campaign_custom_assignment 
		 WHERE campaign_id =2
		   AND quota_id = 1     -- Quota GENERAL (bons 1,2,3)
		   AND quantity > 0
		   )
    AND u.status = 'ACTIVE'
		        
