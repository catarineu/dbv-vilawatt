-- =======================================================================================
-- CONTROL de TEMPS DE VALIDACIÓ DELS BONS
-- =======================================================================================
SELECT date_trunc('month', redemption_request_date), 
	   min(redemption_date - redemption_request_date),
	   avg(redemption_date - redemption_request_date),
	   max(redemption_date - redemption_request_date)
FROM api_voucher av 
WHERE campaign_id =2
  AND status ='REDEEMED'
 GROUP BY date_trunc('month', redemption_request_date)
ORDER BY date_trunc('month', redemption_request_date); 


SELECT date_part('week', redemption_request_date), 
	   min(redemption_date - redemption_request_date),
	   avg(redemption_date - redemption_request_date),
	   max(redemption_date - redemption_request_date)
FROM api_voucher av 
WHERE campaign_id =2
  AND status ='REDEEMED'
 GROUP BY date_part('week', redemption_request_date)
ORDER BY date_part('week', redemption_request_date);

WITH tmp AS 
(SELECT date_trunc('week', redemption_request_date)::date AS week,
	   round((EXTRACT(epoch FROM (redemption_date - redemption_request_date))/3600) / 24)::int AS delay
FROM api_voucher av 
WHERE campaign_id =2
--  AND redemption_request_date BETWEEN '2022-06-27' AND '2022-07-04'
  AND status ='REDEEMED')
SELECT week, 5*(1+(delay / 5)) AS delay, count(*), round(100*count(*)/sum(count(*)) OVER (PARTITION BY week),1) || '%' AS percent
  FROM tmp
GROUP BY week, 5*(1+(delay/ 5))
ORDER BY week, 5*(1+(delay/ 5));


SELECT date_trunc('week', redemption_request_date)::date AS week,
	   round((EXTRACT(epoch FROM (redemption_date - redemption_request_date))/3600) / 24) AS delay,
	   (EXTRACT(epoch FROM (redemption_date - redemption_request_date))/3600) AS delay2
FROM api_voucher av 
WHERE campaign_id =2
  AND status ='REDEEMED'
  AND redemption_request_date BETWEEN '2022-06-27' AND '2022-07-04'
  ORDER BY week

  
SELECT voucher_id, event_type, timestamp, delta,
   	   round((EXTRACT(epoch FROM (delta))/3600) / 24)::int AS delta2
  FROM (SELECT	voucher_id, event_type, "timestamp",
  			"timestamp"-lag("timestamp") over (order by voucher_id DESC, "timestamp") as delta
		 FROM	api_voucher_event_log avel
		WHERE	event_type ~ 'REDEMPTION' 
		  AND   voucher_id  IN (SELECT voucher_id FROM api_voucher_event_log WHERE event_type ~ 'REDEMPTION')
	 ORDER BY	voucher_id DESC, "timestamp") tmp
 WHERE event_type <> 'REDEMPTION_REQUESTED'
 ORDER BY voucher_id DESC, "timestamp";

SELECT date_trunc('week', timestamp)::date AS week,
   	   round((EXTRACT(epoch FROM (delta))/3600) / 24)::int AS delay
  FROM (SELECT	voucher_id, event_type, "timestamp",
  			"timestamp"-lag("timestamp") over (order by voucher_id DESC, "timestamp") as delta
		 FROM	api_voucher_event_log avel
		WHERE	event_type ~ 'REDEMPTION' 
		  AND   voucher_id  IN (SELECT voucher_id FROM api_voucher_event_log WHERE event_type ~ 'REDEMPTION')
	 ORDER BY	voucher_id DESC, "timestamp") tmp
 WHERE event_type <> 'REDEMPTION_REQUESTED'
 ORDER BY voucher_id DESC, "timestamp";

-- Llistat de bons processats per primer cop (acceptats/rebutjats)
--         amb indicació del DeltaT respecte la petició de redempció
--         agrupant per setmana, interval de retard
WITH tmp AS 
(SELECT date_trunc('week', moment)::date AS week,
   	   round((EXTRACT(epoch FROM (delta))/3600) / 24)::int AS delay,
   	   voucher_id
  FROM (SELECT	voucher_id, event_type, "timestamp" AS moment,
  			"timestamp"-lag("timestamp") over (order by voucher_id DESC, "timestamp") as delta
		 FROM	api_voucher_event_log avel
		WHERE	event_type ~ 'REDEMPTION' 
		  AND   timestamp>'2022-01-01'
		  AND   voucher_id  IN (SELECT voucher_id FROM api_voucher_event_log WHERE event_type ~ 'REDEMPTION')
	 ORDER BY	voucher_id DESC, "timestamp") tmp
 WHERE event_type <> 'REDEMPTION_REQUESTED')
SELECT week, 5*(1+(delay / 5)) AS delay, count(*), 
	   round(100*count(*)/sum(count(*)) OVER (PARTITION BY week),1) || '%' AS PERCENT,
	   string_agg(''||voucher_id,',')
  FROM tmp
GROUP BY week, 5*(1+(delay/ 5))
ORDER BY week, 5*(1+(delay/ 5));

-- Llistat d'events de redempció d'un cert subconjunt de bons
--         (agafar voucher_ids del llistat anterior)
SELECT	voucher_id, event_type, "timestamp" AS moment, date_trunc('week', timestamp)::date AS week,
  			"timestamp"-lag("timestamp") over (PARTITION BY voucher_id order by "timestamp") as delta
		 FROM	api_voucher_event_log 
		WHERE	event_type ~ 'REDEMPTION' 
		  AND   timestamp>'2022-01-01'
		  AND   voucher_id  IN (58560,58558,58556,58553,58552,58550,58548,58532,58531,58522,58520,58518,58517,58516,58514,58512,58505,58501,58494,58485,58483,58480,58475,58471,58466,58443,58442,55098,58440,55081,58436,58430,58424,58422,58420,58416,58410,53804,58408,58405,58403,58401,58399,58397,58396,58395,58390,57720,58379,58356,58348,58346,58340,58331,58327,56118,58325,58323,58321,58312,58302,58300,58278,58270,58267,58258,58256,58253,58246,58242,58240,58238,58236,58234,58232,58229,58175,58225,58223,58221,58218,58215,58211,58209,58207,58205,57857,58728,58195,58726,58193,58191,58189,58187,58178,58176,58723,58227,57270,57271,58174,58172,57949,58170,57966,58169,58168,58721,58718,58716,58015,58167,58023,58161,54887,58056,58062,58159,58078,58087,58089,58091,58096,58097,58157,58102,58155,58104,58110,58118,58122,58153,58151,58149,58130,58137,58146,58142,58144,57141,48365,56276,56446,49194,52483,48364,58676,56675,58680,58674,49014,56719,52766,58672,52845,58660,58658,58656,58653,58650,58648,58646,58633,58625,58623,58621,58614,57541,58612,58610,58608,58607,58606,58604,58598,58596,58580,58578,58576,58570,58568,58565)
	 ORDER BY	voucher_id DESC, "timestamp"
