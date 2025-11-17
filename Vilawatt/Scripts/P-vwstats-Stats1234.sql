WITH ranking as
(SELECT payee_name, round(sum(COALESCE(v_redeem,0))) AS total
   FROM mv_payments GROUP BY payee_name) 
SELECT * from ranking	
ORDER BY total desc

-- ===================================================================
SELECT * FROM vw_s1_general();
--DROP FUNCTION vw_s1_general;
CREATE OR REPLACE FUNCTION vw_s1_general()
RETURNS TABLE (
	d_ini date ,
	d_end date ,
	total int4 ,
	to_sale numeric ,
	sold int8 ,
	sold_dif int8 ,
	sold_sum numeric ,
	vouchw_eur numeric ,
	vouchw_eur_dif numeric ,
	vouchw_eur_difpc numeric ,
	oper int8 ,
	oper_dif int8 ,
	vouch_eur numeric ,
	remain numeric ,
	remain_pc numeric 
)
AS $func$
DECLARE
    max_bons INTEGER = 3379;
    init_date DATE = '2023-12-01'::date;
BEGIN
	RETURN QUERY
	SELECT
		a.d_inicial, 
		LEAST(a.d_inicial+6,CURRENT_DATE) as d_final,
		sell_limit as "Total",
		sell_limit-sum(assigned) over (order by d_inicial)+sum(refunded) over (order by d_inicial) as "Per vendre",
		assigned-refunded as "Venuts",
		assigned-lag(assigned) over (order by d_inicial) as "Dif Venuts",
		sum(assigned) over (order by d_inicial)-sum(refunded) over (order by d_inicial) as "Sum Venuts",
		import_bons as "W Bons",
		import_bons-lag(import_bons) over (order by d_inicial) as "Dif W",
		100*round((import_bons-lag(import_bons) over (order by d_inicial))/lag(import_bons) over (order by d_inicial),2) as "% Dif W",
		c.num_ops as "Ops",
		c.num_ops-lag(c.num_ops) over (order by d_inicial) as "Dif Ops",
		sum(import_bons) over (order by d_inicial) as "WBons",
		50*sell_limit - sum(import_bons) over (order by d_inicial) as pendent,
		round(100*(50*sell_limit - sum(import_bons) over (order by d_inicial))/(50*sell_limit)) as pendent_pc
	FROM
		(
		SELECT
			date_trunc('week', "timestamp")::date as d_inicial,
			sum(case when event_type = 'ASSIGNED' then 1 else 0 end) as assigned,
			sum(case when event_type = 'REDEEMED' then 1 else 0 end) as redeemed,
			sum(case when event_type = 'REFUNDED' then 1 else 0 end) as refunded
		FROM
			api_voucher_event_log vel
		WHERE timestamp >= init_date
		GROUP BY
			date_trunc('week', "timestamp")::date
	    ) a 
	    LEFT OUTER JOIN
	    (SELECT
			date_trunc('week', process_date)::date as d_inicial,
			count(composite_transaction_id) as num_bons,
			sum(redeem_amount) as import_bons
		FROM
			api_composite_transaction ct
		LEFT OUTER JOIN api_composite_transaction_vouchers ctv on ct.id = ctv.composite_transaction_id
		LEFT OUTER JOIN api_voucher v  on ctv.voucher_id = v.id 
		WHERE
			ticket_status = 'PROCESSED'
			AND ticket_type = 'QR_CODE'
			AND v.status <> 'MERGED'     -- no s'han de comptar perquè s'han regenerat (proves bons)
		    AND process_date >= init_date
		GROUP BY
			date_trunc('week', process_date)::date
		HAVING
			count(composite_transaction_id) > 0
	    ) b USING (d_inicial)
	    LEFT OUTER JOIN
	    (SELECT
			date_trunc('week', process_date)::date as d_inicial,
			count(*) as num_ops
		FROM
			api_composite_transaction ct
		WHERE process_date >= init_date
		GROUP BY
			date_trunc('week', process_date)::date
	    ) c USING (d_inicial),
	    LATERAL (SELECT CASE WHEN d_inicial<init_date then max_bons else max_bons end ) as s1 (sell_limit)
	ORDER BY 
		d_inicial DESC; 
END;
$func$ LANGUAGE plpgsql;

	
-- INFORME #2 -- Control d'usuaris
-- ===================================================================
SELECT * FROM vw_s2_users();
--DROP FUNCTION vw_s2_users;
CREATE OR REPLACE FUNCTION vw_s2_users()
RETURNS TABLE (
	month date ,
	aut_num int8 ,
	aut_sum numeric ,
	emp_num int8 ,
	emp_sum numeric ,
	ent_num int8 ,
	ent_sum numeric ,
	par_num int8 ,
	par_sum numeric ,
	total_month int8 ,
	total_sum numeric 
)
AS $func$
DECLARE
    init_date DATE = '2019-07-01'::date;
BEGIN
	RETURN QUERY
		SELECT
		     mes,
		     aut, sum(aut) over (order by mes) as s_aut,
		     emp, sum(emp) over (order by mes) as s_emp,
		     ent, sum(ent) over (order by mes) as s_ent,
		     par, sum(par) over (order by mes) as s_par,
		     aut+emp+ent+par as total, sum(aut+emp+ent+par) over (order by mes) as s_total
		FROM (
			SELECT 
				date_trunc('month', u.creation_date)::date as mes,
				sum(case when g.id=16 then 1 else 0 end) as aut,
				sum(case when g.id=17 then 1 else 0 end) as emp,
				sum(case when g.id=18 then 1 else 0 end) as ent,
				sum(case when g.id=19 then 1 else 0 end) as par
			FROM 
				cyclos_users u 
				LEFT OUTER JOIN cyclos_groups g on	(u.user_group_id = g.id)
			WHERE 
				u.network_id =2 -- Vilawatt live
				AND creation_date > init_date -- Official kick-off date
				AND u.status ='ACTIVE'
			GROUP BY date_trunc('month', creation_date)::date 
			) a
		ORDER BY mes DESC;
END;
$func$ LANGUAGE plpgsql;

-- INFORME #3 -- Bons per comerç - Resum
-- ===================================================================
SELECT * FROM vw_s3_merchants_totals('2024-12-01');
--DROP FUNCTION vw_s3_merchants_totals;
CREATE OR REPLACE FUNCTION vw_s3_merchants_totals()
RETURNS TABLE (
	name text ,
	voucher_num int8 ,
	voucher_sum numeric ,
	voucher_pc  numeric ,
	avg_ticket numeric 
)
AS $func$
DECLARE
    init_date DATE = '2023-12-01'::date;
BEGIN
	RETURN QUERY
		SELECT
			est_nom,
			num_bons,
			import_bons,
			round(100 * import_bons / sum(import_bons) OVER (), 1) AS PERCENT,
			round(mitja, 1) AS mitja
		FROM
			(
				SELECT
					--	payee_id as est_id
					trim(regexp_replace(payee_name, ' \(.*', '')) AS est_nom,
					count(composite_transaction_id) AS num_bons,
					sum(redeem_amount) AS import_bons,
					avg(redeem_amount) AS mitja
				FROM
					api_composite_transaction ct
				LEFT OUTER JOIN api_composite_transaction_vouchers ctv  ON ct.id = ctv.composite_transaction_id
				LEFT OUTER JOIN api_voucher v 							ON ctv.voucher_id = v.id
				WHERE
					ticket_status = 'PROCESSED'
					AND ticket_type = 'QR_CODE'
					AND v.status <> 'MERGED'
					-- no s'han de comptar perquè s'han regenerat (proves bons)	
					AND process_date >= init_date
				GROUP BY
					trim(regexp_replace(payee_name, ' \(.*', ''))
				HAVING
					count(composite_transaction_id) > 0
			) a
		ORDER BY
			import_bons DESC;
END;
$func$ LANGUAGE plpgsql;



-- INFORME #4 -- Bons per comerç - Detall
-- ===================================================================
SELECT * FROM vw_s4_merchants_detail('2024-12-01');
--DROP FUNCTION vw_s4_merchants_detail;
CREATE OR REPLACE FUNCTION vw_s4_merchants_detail()
RETURNS TABLE (
	merchant text ,
	op_ip int8 ,
	customer text ,
	date timestamp ,
	amount numeric(19, 2) ,
	voucher_num int8 ,
	voucher_codes text ,
	voucher_sum numeric 
)
AS $func$
DECLARE
    init_date DATE = '2023-12-01'::date;
BEGIN
	RETURN QUERY
		SELECT
			trim(regexp_replace(payee_name, ' \(.*', '')) AS establiment,
			ct.id AS id_venta,
			LEFT(md5('' || payer_id), 6) AS client_venta,
			process_date AS data_venta2,
			ct.amount AS import_venta,
			count(composite_transaction_id) AS num_bons,
			string_agg(LEFT(v.code, 8)|| ' (' || redeem_amount || '₩)', ', ') AS bons_codes,
			sum(redeem_amount) AS import_bons
		FROM
			api_composite_transaction ct 
			LEFT OUTER JOIN api_composite_transaction_vouchers ctv 	ON	ct.id = ctv.composite_transaction_id
			LEFT OUTER JOIN api_voucher v 							ON	ctv.voucher_id = v.id
		WHERE
			ticket_status = 'PROCESSED'
			AND ticket_type = 'QR_CODE'
			AND v.status <> 'MERGED'
			-- no s'han de comptar perquè s'han regenerat (proves bons)
			AND process_date >= init_date
			AND payee_name='Electrodomèstics Calbet 1'
			--	and payee_name ~ '^Electro'
		GROUP BY GROUPING SETS (  
			(payee_name, LEFT(md5('' || payer_id), 6), process_date,	ct.amount,	ct.id),(payee_name))
		HAVING
			count(composite_transaction_id) > 0
		ORDER BY
			trim(regexp_replace(payee_name, ' \(.*', '')),
			process_date::date DESC NULLS LAST;
END;
$func$ LANGUAGE plpgsql;
		

WITH usuaris AS (
	SELECT idcypher(id) AS id, name FROM cyclos_users cu2 
);

WITH totals AS ( 
SELECT iddecypher(user_id), 
--		sum(CASE WHEN campaign_id=7 THEN quantity ELSE 0 END) AS bons_total,
		sum(CASE WHEN campaign_id=7 THEN spent    ELSE 0 END) AS bons_spent,
--		sum(CASE WHEN campaign_id=8 THEN quantity ELSE 0 END) AS verds_total,
		sum(CASE WHEN campaign_id=8 THEN spent    ELSE 0 END) AS verds_spent,
		sum(CASE WHEN campaign_id=7 THEN spent    ELSE 0 END) +
		sum(CASE WHEN campaign_id=8 THEN spent    ELSE 0 END) AS total
  FROM vwapi.voucher_campaign_custom_assignment vcca
--       LEFT OUTER JOIN usuaris cu ON cu.id=vcca.user_id
 WHERE 1=1
   AND "timestamp" >= '2024-12-01'
   AND spent > 0
GROUP BY iddecypher(user_id)
)
SELECT *, total*50 AS impacte FROM totals ORDER BY total DESC, bons_spent DESC, verds_spent DESC;


SELECT * FROM cyclos_users cu WHERE iddecypher(-5646242751872640362)=cu.id;

		