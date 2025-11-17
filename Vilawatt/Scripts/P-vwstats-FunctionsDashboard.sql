--======================================================
--● Masa monetaria en circulación: 179.827,57 ₩
--------------------------------------------------------
--● Registro de particulares: 2.297 
--● Registro comercio y empresa: 431  
--● Comercio y empresa visible en la App: 190 
--● Entidades sin ánimo de lucro y administración pública: 20
--------------------------------------------------------
--● Número de bonos vendidos: 5.723
--● Número de bonos en circulación: 1.984
--● Importe ingresado por cupones en circulación: 31.598,78 ₩
--● Importe ingresado por cupones vendidos: 143.075,00 ₩
--● Valor total de cupones vendidos: 286.150,00 ₩
--======================================================

SELECT grup , count(*) 
  FROM mv_cyclos_users mcu
 WHERE status = 'ACTIVE'
 GROUP BY grup
 ORDER BY grup;

SELECT * FROM cyclos_users cu WHERE 

-- ===================================================================================================
-- ===================================================================================================
SELECT * FROM vw_b1_cercanom('catarineu');

DROP FUNCTION public.vw_b1_cercanom(cerca character varying);
CREATE OR REPLACE FUNCTION public.vw_b1_cercanom(cerca character varying)
 RETURNS TABLE(uid integer, fullname character varying, usuari text, correu text, dni text, tipus character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
    SELECT mcu.id::int AS uid, name AS fullname, username AS usuari, email AS correu, mcu.dni AS dni, grup AS tipus
      FROM mv_cyclos_users mcu 
     WHERE mcu.username ~* cerca 
        OR mcu.dni      ~* cerca
        OR mcu.name     ~* cerca
     ORDER BY name; 
END;
$function$
;
;

-- ===================================================================================================
-- ===================================================================================================
SELECT * FROM vw_b2_bonsassignats(24);

DROP FUNCTION public.vw_b2_bonsassignats(uid integer);
CREATE OR REPLACE FUNCTION public.vw_b2_bonsassignats(uid integer)
 RETURNS TABLE(data date, motiu character varying, num_bons integer, codi character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
		SELECT
			timestamp::date AS DATA,
			COMMENT AS motiu,
			quantity AS num_bons,
			reason AS codi
		FROM
			api_voucher_campaign_custom_assignment_delta avccad
		WHERE
			user_id = idcypher(uid)
			AND hidden = FALSE
		ORDER BY
			timestamp;
END;
$function$
;


-- ===================================================================================================
-- ===================================================================================================
SELECT * FROM vw_b3_controlvld(24);

DROP FUNCTION public.vw_b3_controlvld(uid integer);
CREATE OR REPLACE FUNCTION public.vw_b3_controlvld(uid integer)
 RETURNS TABLE(nom character varying, valor character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
		SELECT cucf."name" AS nom, string_value AS valor
		  FROM cyclos_user_custom_field_values ucfv1
			   LEFT OUTER JOIN cyclos_user_custom_fields cucf ON (cucf.id=ucfv1.field_id) 
		 WHERE ucfv1.owner_id = uid
		   AND ucfv1.field_id IN (77, 78, 79, 80)
	UNION
		SELECT 'O- Whitelist (treballa a VLD)' AS nom, 
			   CASE WHEN uid IN (SELECT id FROM  tmp_white_workers tww) THEN 'TRUE' ELSE 'FALSE' END
	UNION
		SELECT 'O- Accés a bons 1-2 per ERROR' AS nom, 
			   CASE WHEN uid IN (SELECT id FROM  tmp_white_cheaters twc) THEN 'TRUE' ELSE 'FALSE' END
	ORDER BY nom;
END;
$function$
;


-- ===================================================================================================
-- ===================================================================================================
SELECT * FROM vw_b4_reportBons(24,'2021-01-01');

DROP FUNCTION public.vw_b4_reportBons(uid int, inici date);
CREATE OR REPLACE FUNCTION public.vw_b4_reportBons(uid int, inici date)
 RETURNS TABLE(moment timestamp(0), origen text, desti text, tipus text, 
 			   IMPORT NUMERIC, i_saldo NUMERIC, i_bons NUMERIC, idbons text,
 			   origen_grup text, desti_grup text, info text)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
	    SELECT -- FUSIÓ 1: CONSULTA moviments PAGAMENTS_COMPOSTOS
			   min(process_date)::timestamp(0) AS date,  
			   LEFT(payer_name,20)||'...('||iddecypher(payer_id)||')' AS payer, 
			   LEFT(payee_name,20)||'...('||iddecypher(payee_id)||')' AS payee, 
			   '*** Pagament APP ***'::text AS t_type, 
			   CASE WHEN payee_id=idcypher(uid) THEN t_amount ELSE -t_amount END AS amount, 
		       -t_due AS w_saldo, 
		       CASE WHEN payee_id=idcypher(uid) THEN sum(v_redeem) ELSE -sum(v_redeem) END  AS w_bons,
		       string_agg(''||v_redeem,';') AS bons, LEFT(payer_grup,20) AS payer_grup , LEFT(payee_grup,20) AS payee_grup,
		       'txs=' AS info
		  FROM mv_payments 
		  WHERE (payer_id = idcypher(uid) OR payee_id = idcypher(uid))
		    AND process_date > inici
		 GROUP BY id, payer_name, payee_name, payer_id, payee_id, t_amount, payer_grup , payee_grup, t_due
	UNION
		SELECT  -- FUSIÓ 2: CONSULTA moviments CYCLOS
			t."date"::timestamp(0), 
			LEFT(mcu1.name,20)||'...('||mcu1.id||')' AS payer,
			LEFT(mcu2.name,20)||'...('||mcu2.id||')' AS payee, tt.name AS t_type, 
			CASE WHEN mcu2.id=a.user_id THEN t.amount ELSE -t.amount END AS amount, 
			CASE WHEN mcu2.id=a.user_id THEN t.amount ELSE -t.amount END AS w_saldo, 0 AS w_bons, NULL AS bons, 
			LEFT(mcu1.grup,20) AS payer_group, LEFT(mcu2.grup,20) AS payee_group, 
			t.subclass ||',  tx='|| t.transaction_number ||',  tid='|| t.id AS details
		FROM
			cyclos_accounts a 
			LEFT OUTER JOIN cyclos_transfers t ON (t.from_id=a.id OR t.to_id=a.id)
			LEFT OUTER JOIN cyclos_transfer_types tt ON (t.type_id=tt.id)
			LEFT OUTER JOIN cyclos_accounts a1 ON (a1.id=t.from_id)
			LEFT OUTER JOIN cyclos_accounts a2 ON (a2.id=t.to_id)
			LEFT OUTER JOIN mv_cyclos_users mcu1 ON (mcu1.id=a1.user_id)
			LEFT OUTER JOIN mv_cyclos_users mcu2 ON (mcu2.id=a2.user_id)
		WHERE
			date > inici
			AND a.user_id = uid
	UNION 
		SELECT -- FUSIÓ 3: CONSULTA moviments de bons
		    COALESCE(
			CASE WHEN vel.event_type='SPLIT'    THEN assignment_date -- BUG JJ: Sense ASSIGNED, em cal això per mostrar els bons que han acabat en SPLIT
			     WHEN vel.event_type='ASSIGNED' THEN assignment_date
			     WHEN vel.event_type='SPENT'    THEN spend_date
			     WHEN vel               IS NULL THEN issue_date
			END, timestamp)::timestamp(0) AS date,
			LEFT(mcu1.name,20)||'...('||mcu1.id||')' AS payer, 
			LEFT(mcu2.name,20)||'...('||mcu2.id||')' AS payee,
			'→ Voucher ' || COALESCE(vel.event_type,'ASSIGNED++') AS t_type,  -- BUG JJ: Sense ASSIGNED, em cal això per mostrar els bons que NO han acabat en SPLIT
			av.amount AS amount, 0 AS w_saldo, av.amount AS w_bons, NULL AS bons,
			LEFT(mcu1.grup,20) AS payee_grup, LEFT(mcu2.grup,20) AS payee_grup, 
			'c='||av.campaign_id||',vid='||av.id||
			CASE WHEN av.parent_id IS NOT NULL THEN ',vparent='||av.parent_id ELSE '' END ||
			CASE WHEN av.root_id   IS NOT NULL THEN ',vroot='||av.root_id ELSE '' END || 
			CASE WHEN vel.transaction_context_id IS NOT NULL THEN ',tx='||vel.transaction_context_id ELSE '' END AS info
		FROM 
			api_voucher av
			LEFT OUTER JOIN api_voucher_event_log vel ON (av.id=vel.voucher_id)
			LEFT OUTER JOIN mv_cyclos_users mcu1 ON (vel.from_user_id=mcu1.idcyclos)
			LEFT OUTER JOIN mv_cyclos_users mcu2 ON (vel.to_user_id  =mcu2.idcyclos)
		WHERE
			av.assignee_id = idcypher(uid)
			AND (vel.event_type NOT IN ('ISSUED', 'REDEMPTION_REQUESTED', 'REDEMPTION_APPROVED', 'REDEEMED') OR vel.event_type IS NULL)
			AND	assignment_date > inici
	UNION
		SELECT -- FUSIÓ 4: CONSULTA saldo actual en ₩ de l'usuari
			now()::timestamp(0) AS date, 
			NULL AS payer, mcu."name"||' ('||mcu.id||')' AS payee, 
			'SALDO ACTUAL' as t_type, 0 AS amount, ab.balance AS w_saldo, 0 AS w_bons, NULL AS bons,
			NULL AS payer_grup, LEFT(mcu.grup,20) AS payee_grup, NULL AS info
		FROM
			cyclos_accounts a
			LEFT OUTER JOIN cyclos_account_balances ab ON (ab.account_id=a.id)
			LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.id=a.user_id)
		WHERE
			user_id = uid
	ORDER BY date, t_type;
END;
$function$
;


-- ===================================================================================================
-- ===================================================================================================
SELECT * FROM vw_b5_lastBonsGiven(7);

DROP FUNCTION public.vw_b5_lastBonsGiven(dies int);
CREATE OR REPLACE FUNCTION public.vw_b5_lastBonsGiven(dies int)
 RETURNS TABLE(moment timestamp(0), nom varchar, id bigint, username text, 
 			   grup varchar, quant int, COMMENT varchar, white text)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
		-- Per què se li han assignat bons
		SELECT avccad.timestamp::timestamp(0) , mcu."name", mcu.id, mcu.username, mcu.grup, avccad.quantity AS bons, avccad."comment" , 
			   CASE WHEN tww.id IS NOT NULL THEN 'Sí' ELSE 'No' END AS whitelist
		FROM api_voucher_campaign_custom_assignment_delta avccad
			 LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.idcyclos=avccad.user_id) 
			 LEFT OUTER JOIN tmp_white_workers tww ON (tww.id=mcu.id)
		WHERE "timestamp" >= now() - (dies||' days')::INTERVAL
		  AND avccad.hidden = FALSE 
		ORDER BY timestamp DESC, id;
END;
$function$
;

