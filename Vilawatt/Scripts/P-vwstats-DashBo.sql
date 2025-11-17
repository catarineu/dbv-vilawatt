-- Bons emesos, venuts, usats (orig+fills) i expropiats
SELECT
	7385 AS emesos,
	sum(CASE WHEN event_type = 'ASSIGNED' THEN 1 ELSE 0 END) AS venuts,
	sum(CASE WHEN event_type = 'REDEEMED' THEN 1 ELSE 0 END) AS usats,
	sum(CASE WHEN event_type = 'REFUNDED' THEN 1 ELSE 0 END) AS expropiats
FROM
	api_voucher_event_log vel
WHERE
	timestamp >= '2021-12-25';

-- Bons ORIG usats al 100% (sense SPLIT)
SELECT
	count(*)
FROM
	api_voucher_event_log vel
WHERE
	event_type = 'REDEEMED'
	AND
	voucher_id IN (
		SELECT	voucher_id
		FROM	api_voucher_event_log avel
		WHERE	event_type = 'ASSIGNED'
	)
	AND
	timestamp >= '2021-12-25';

-- Detall de root_coupons, amb deglós de child_coupons
SELECT
	COALESCE(rv.code, v.code) AS root_code,
	v.code,
	ct.id AS ct_id, ct.process_date,
	COALESCE(rv.amount, v.amount) AS original_voucher_amount,
	ctv.redeem_amount
--	sf.*
FROM
	api_voucher v
	JOIN api_composite_transaction_vouchers ctv ON	ctv.voucher_id = v.id
	JOIN api_composite_transaction ct 			ON	ct.id = ctv.composite_transaction_id
	JOIN api_composite_transaction_attachment cta ON	cta.transaction_id = ct.id
	LEFT JOIN api_voucher rv 					ON	rv.id = v.root_id
WHERE
	cta.type = 'TICKET' 
AND v.status = 'REDEEMED'
AND ct.process_date >= '2021-12-25'	
ORDER BY root_code;

SELECT userid, cu.name, root_code, dcompra, num AS usos, amount AS import
 FROM 
   (SELECT
		COALESCE(rv.code, v.code) AS root_code, COALESCE(rv.assignment_date, v.assignment_date) AS dcompra,
		iddecypher(v.assignee_id) AS userid,
		count(ct.id) AS num, sum(ctv.redeem_amount) AS amount
	FROM
		api_voucher v
		JOIN api_composite_transaction_vouchers ctv ON	ctv.voucher_id = v.id
		JOIN api_composite_transaction ct 			ON	ct.id = ctv.composite_transaction_id
		LEFT JOIN api_voucher rv 					ON	rv.id = v.root_id
	WHERE
	    v.status = 'REDEEMED'
	AND ct.process_date >= '2021-12-25'	
	GROUP BY COALESCE(rv.code, v.code), COALESCE(rv.assignment_date, v.assignment_date), v.assignee_id) a
  LEFT OUTER JOIN cyclos_users cu  ON cu.id = a.userid
ORDER BY userid, dcompra;

SELECT userid, cu.name, min(dcompra) AS inici, max(dcompra)-min(dcompra) AS span, count(root_code) AS nbons, sum(num) AS usos, sum(amount) AS import
 FROM 
   (SELECT
		COALESCE(rv.code, v.code) AS root_code, COALESCE(rv.assignment_date, v.assignment_date) AS dcompra,
		iddecypher(v.assignee_id) AS userid,
		count(ct.id) AS num, sum(ctv.redeem_amount) AS amount
	FROM
		api_voucher v
		JOIN api_composite_transaction_vouchers ctv ON	ctv.voucher_id = v.id
		JOIN api_composite_transaction ct 			ON	ct.id = ctv.composite_transaction_id
		LEFT JOIN api_voucher rv 					ON	rv.id = v.root_id
	WHERE
	    v.status = 'REDEEMED'
	AND ct.process_date >= '2021-12-25'	
	GROUP BY COALESCE(rv.code, v.code), COALESCE(rv.assignment_date, v.assignment_date), v.assignee_id) a
  LEFT OUTER JOIN cyclos_users cu  ON cu.id = a.userid
  GROUP BY userid, cu.name
  ORDER BY nbons, userid;

-- Ops/Eur d'imapcte als comerços
SELECT
	count(composite_transaction_id) AS ops_m,
	sum(redeem_amount) AS w_ops_m
FROM
	api_composite_transaction ct
	LEFT OUTER JOIN api_composite_transaction_vouchers ctv 	ON	ct.id = ctv.composite_transaction_id
	LEFT OUTER JOIN api_voucher v 							ON	ctv.voucher_id = v.id
WHERE
	ticket_status = 'PROCESSED'
	AND ticket_type = 'QR_CODE'
	AND v.status <> 'MERGED' 			-- no s'han de comptar perquè s'han regenerat (proves bons)
	AND process_date >= '2021-12-25'
HAVING
	count(composite_transaction_id) > 0;
