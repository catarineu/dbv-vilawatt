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
	AND process_date >= '2023-12-01'
	--	and payee_name ~ '^Electro'
GROUP BY  
	payee_name, LEFT(md5('' || payer_id), 6), process_date,	ct.amount,	ct.id
HAVING
	count(composite_transaction_id) > 0
ORDER BY
	trim(regexp_replace(payee_name, ' \(.*', '')),
	process_date::date DESC NULLS LAST;
	

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
			AND process_date >= '2023-12-01'
		GROUP BY
			trim(regexp_replace(payee_name, ' \(.*', ''))
		HAVING
			count(composite_transaction_id) > 0
	) a
ORDER BY
	import_bons DESC;