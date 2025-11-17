


CREATE OR REPLACE PROCEDURE cron_bons12 ()  
LANGUAGE plpgsql  
AS  $$  
DECLARE  
	nrows int;
BEGIN
--	WITH (
--		INSERT INTO	api_voucher_campaign_custom_assignment_delta
	WITH myrows AS (
		INSERT INTO	api_voucher_campaign_custom_assignment_delta
		   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
		   (SELECT 'BW2022 1-2', 2, 'Bons 1-2: Per domicili a Viladecans', 
		           now(), idcypher(u.id), 2, 1
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
					-- Ja se'ls ha assignat un 3r bo
					SELECT iddecypher(user_id)
					  FROM api_voucher_campaign_custom_assignment 
					 WHERE campaign_id =2
					   AND quota_id = 1     -- Quota GENERAL (bons 1 i 2)
					   AND quantity > 0
					   )
		        AND u.status = 'ACTIVE'
			) RETURNING 1
		) SELECT count(*) INTO nrows FROM myrows;
		
		RAISE NOTICE 'Ha funcionat be: % files inserides', nrows;
END  $$