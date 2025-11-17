/*SELECT owner_id, ucfv1.string_value, ucfv1.field_id
  FROM cyclos_user_custom_field_values ucfv1 
 WHERE ucfv1.owner_id = 24 ORDER BY field_id */

DROP MATERIALIZED VIEW mv_cyclos_users;
CREATE MATERIALIZED VIEW mv_cyclos_users AS
	SELECT cu.id, cu."name", lower(cu.username) AS username, upper(cucfv2.string_value) AS dni, idcypher(cu.id) AS idcyclos, status, 
	       lower(cu.email) AS email, upper(cucfv3.string_value) AS telef,
		   cucfv1.date_value::date AS naix, cg."name" AS grup, cu.creation_date  
	FROM cyclos_users cu 
		LEFT OUTER JOIN cyclos_user_custom_field_values cucfv1 ON (cucfv1.owner_id = cu.id AND cucfv1.field_id = 21)
		LEFT OUTER JOIN cyclos_user_custom_field_values cucfv2 ON (cucfv2.owner_id = cu.id AND cucfv2.field_id = 23)
		LEFT OUTER JOIN cyclos_user_custom_field_values cucfv3 ON (cucfv3.owner_id = cu.id AND cucfv3.field_id = 54)
		LEFT OUTER JOIN cyclos_groups cg ON (cg.id = cu.user_group_id AND cg.network_id = 2)
	WHERE cu.network_id = 2;

SELECT * FROM mv_payments;

DROP MATERIALIZED VIEW mv_payments;
CREATE MATERIALIZED VIEW mv_payments AS 
   (WITH pags AS (
	SELECT act.id, act.payer_name, act.payee_name,  
		   act.amount AS t_amount, act.due_amount t_due, 
		   actv.due_amount AS v_due, redeem_amount AS v_redeem,
		   actp.amount AS p_amount,
		   act.payer_id, act.payee_id, process_date 
	  FROM api_composite_transaction act 
	  	   LEFT OUTER JOIN api_composite_transaction_vouchers actv 
	       ON (actv.composite_transaction_id=act.id)
	       LEFT OUTER JOIN  api_composite_transaction_payments actp 
	       ON (actp.composite_transaction_id=act.id)
	 WHERE ticket_status = 'PROCESSED'
	       AND process_date >= '2022-01-01'
	) 
	SELECT pags.*,
		   mcu1.grup AS payer_grup, mcu2.grup AS payee_grup
	  FROM pags
	       LEFT OUTER JOIN mv_cyclos_users mcu1 ON (pags.payer_id=mcu1.idcyclos)
	       LEFT OUTER JOIN mv_cyclos_users mcu2 ON (pags.payee_id=mcu2.idcyclos)
	);

DROP MATERIALIZED VIEW mv_bonusers_prod;
CREATE MATERIALIZED VIEW mv_bonusers_prod AS
	SELECT
		cu.id, cu.status,
		cu.username,
		cu.name,
		cu.grup,
		cuc.dni AS DNI,
		COALESCE(giv.given,0) AS given,
		COALESCE(bv.bought,0) AS bought,
		COALESCE(vcca.given,0) AS given_vcca,
		COALESCE(vcca.bought,0) AS bought_vcca
	--	string_agg(td2.reason || ' (' || td2.quantity || ')', ', ')
	FROM
		mv_cyclos_users cu
		LEFT OUTER JOIN (
		   SELECT user_id AS idcyclos, iddecypher(td.user_id) AS id, SUM(td.quantity) AS given
		  	 FROM  api_voucher_campaign_custom_assignment_delta td
			WHERE campaign_id = 2 AND hidden=FALSE 
			GROUP BY user_id, iddecypher(td.user_id)
		) giv ON (cu.id=giv.id)
		LEFT OUTER JOIN (
			SELECT assignee_id, count(*) AS bought
			  FROM api_voucher av
	 		 WHERE parent_id IS NULL
			   AND campaign_id = 2
			   AND status <> 'REFUNDED'
			 GROUP BY assignee_id) bv 	ON (bv.assignee_id = cu.idcyclos)
	    LEFT OUTER JOIN (
			SELECT user_id, sum(quantity) AS given, sum(spent) AS bought
			  FROM api_voucher_campaign_custom_assignment ca 
	 		 WHERE campaign_id = 2
			 GROUP BY user_id) vcca	ON (vcca.user_id = cu.idcyclos)
		LEFT OUTER JOIN (
			SELECT owner_id, string_agg(COALESCE(cucfv.string_value,''),'') AS dni
			  FROM cyclos_user_custom_field_values cucfv  
 			 WHERE field_id IN (23,46)
 			 GROUP BY owner_id
			  ) cuc ON (cuc.owner_id = cu.id);
