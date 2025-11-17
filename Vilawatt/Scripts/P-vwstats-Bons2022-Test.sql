---------------------------------------------------------------
-- RESUM DELS BONS ASSIGNATS ALS USUARIS ----------------------
---------------------------------------------------------------
SELECT reason, "comment", count(*) AS usuaris, sum(td.quantity) AS bons, avcq."name" AS quota, avcq.quantity AS "Q-limit"
FROM tmp_delta td ,
       api_voucher_campaign_quota avcq 
WHERE avcq.id = td.quota_id 
GROUP BY GROUPING SETS ((reason, avcq."name", "comment", avcq.quantity),())
ORDER BY reason, comment;

DELETE FROM tmp_delta;
-- =============== WHITELIST (1A): Dos bons inicials (viuen VLD) ===============================
-- =============== WHITELIST (1A) ============================================ WHITELIST ============
-- =============== WHITELIST (1A) ============================================ WHITELIST ============
-- =============== WHITELIST (1A) ============================================ WHITELIST ============
INSERT xx INTO	tmp_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 1-2', 2, 'Bons 1-2: Per domicili a Viladecans', 
           now(), idcypher(u.id), 2, 1
	FROM
		cyclos_users u
	WHERE
		u.network_id = 2
		AND u.id IN (
			SELECT owner_id
			  FROM cyclos_user_custom_field_values ucfv1 
		     WHERE ucfv1.owner_id = u.id
 		       AND ucfv1.string_value ~* '08840'
		       AND ucfv1.field_id IN (77, 78, 79, 80)
		       )
        AND u.status = 'ACTIVE'
	);

-- =============== WHITELIST (1B): Dos bons inicials (treballen VLD) =============================
INSERT xx INTO	tmp_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 1-2', 2, 'Bons 1-2: Per treballar a Viladecans', 
           now(), idcypher(u.id), 2, 1
	FROM
		cyclos_users u
	WHERE
		u.id IN (SELECT id FROM tmp_white_workers)
		AND u.status = 'ACTIVE');

-- =============== WHITELIST (1C): Dos bons inicials (cheaters VLD) =============================
INSERT xx INTO	tmp_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 1-2', 2, 'Bons 1-2: Per domicili(*) a Viladecans',
           now(), idcypher(u.id), 2, 1
	FROM
		cyclos_users u
	WHERE
		u.network_id = 2
		AND u.id IN (SELECT id FROM tmp_white_cheaters));

-- =============== WHITELIST (2): Recompra bons 2020 =============================
-- =============== WHITELIST (2) ============================================ WHITELIST ============
-- =============== WHITELIST (2) ============================================ WHITELIST ============
-- =============== WHITELIST (2) ============================================ WHITELIST ============
-- Campaign_id = 2 (Bons Vilawat 2022)
INSERT xx INTO	tmp_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 Rebuy2020', a.num, 'Recompra BW2020: Per expropiació 2021-12', 
           now(), assignee_id, 2, 3
	FROM
		(SELECT txu.username, num, assignee_id
		FROM 
		  ( SELECT
		  		assignee_id, CEILING(sum(price)/ 25) AS num
			FROM
				(	SELECT
						v.assignee_id, v.price
					FROM
						api_voucher v
					LEFT JOIN api_voucher_campaign c ON v.campaign_id = c.id
					WHERE
						v.campaign_id = 1
						AND v.status = 'REFUNDED'
						AND v.refund_date >= c.end_date
					ORDER BY
						assignee_id
				) my_vouchers
			GROUP BY
				assignee_id
		) bons2020,	mv_cyclos_users txu
		where 
		      assignee_id=txu.idcyclos
		  and status='ACTIVE'
		order by username) a);

-- =============== WHITELIST (3): Tercer bo (habitants VLD) =============================
-- =============== WHITELIST (3) ============================================ WHITELIST ============
-- =============== WHITELIST (3) ============================================ WHITELIST ============
-- =============== WHITELIST (3) ============================================ WHITELIST ============
--DELETE FROM  tmp_delta WHERE reason='BW2022 3';
INSERT xx INTO	tmp_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 3', 1, 'Bo 3: Per domicili a Viladecans', 
           now(), idcypher(u.id), 2, 2
	FROM
		cyclos_users u
	WHERE
		u.network_id = 2
		AND u.id IN (
			SELECT owner_id
			  FROM cyclos_user_custom_field_values ucfv1 
		     WHERE ucfv1.owner_id = u.id
 		       AND ucfv1.string_value ~* '08840'
		       AND ucfv1.field_id IN (77, 78, 79, 80)
		       )
        AND u.status = 'ACTIVE'
	);

-- Llistat del que donem als cheaters/workers
SELECT
	w.id, w.username, sum(quantity) AS total, string_agg(reason || ' (' || "comment" || '--' || quantity ||')', ', ')
FROM
	tmp_white_cheaters w
	LEFT OUTER JOIN tmp_delta td ON (iddecypher(td.user_id)=w.id)
GROUP BY w.id, w.username
ORDER BY id;


-- ================================
-- DETALL: De bons GIVEN i BOUGHT
DROP TABLE tmp_bonusers;
CREATE TABLE tmp_bonusers AS (
	SELECT
		cu.id, cu.status,
		cu.username,
		cu.name,
		cu.grup,
		cucfv1.string_value AS DNI,
		COALESCE(giv.given,0) AS given,
		COALESCE(bv.bought,0) AS bought
	--	string_agg(td2.reason || ' (' || td2.quantity || ')', ', ')
	FROM
		mv_cyclos_users cu
		LEFT OUTER JOIN (
		   SELECT user_id AS idcyclos, iddecypher(td.user_id) AS id, SUM(td.quantity) AS given
		  	 FROM  api_voucher_campaign_custom_assignment_delta td
			WHERE campaign_id = 2
			GROUP BY user_id, iddecypher(td.user_id)
		) giv ON (cu.id=giv.id)
		LEFT OUTER JOIN (
			SELECT assignee_id, count(*) AS bought
			  FROM api_voucher av
	 		 WHERE parent_id IS NULL
			   AND campaign_id = 2
			   AND status <> 'REFUNDED'
			 GROUP BY assignee_id) bv 	ON (bv.assignee_id = cu.idcyclos)
		LEFT OUTER JOIN cyclos_user_custom_field_values cucfv1 ON (cucfv1.owner_id = cu.id AND cucfv1.field_id IN (23,46))
);

SELECT grup, given, bought, count(*)
  FROM tmp_bonusers 
 GROUP BY GROUPING SETS ((grup, given, bought),())
 ORDER BY grup, given, bought;

SELECT status, grup, 
	   count(DISTINCT dni) AS n_usu, 
	   sum(CASE WHEN given > 0 THEN 1 ELSE 0 END) AS n_given,
	   sum(CASE WHEN bought > 0 THEN 1 ELSE 0 END) AS n_buy, 
       sum(given) AS given, sum(bought) AS bought 
 FROM tmp_bonusers n
GROUP BY GROUPING SETS ((status, grup),(status),())
ORDER BY status, grup NULLS LAST;

SELECT id, name, "type" 
FROM cyclos_user_custom_fields cucf 
WHERE network_id = 2 AND "type" NOT IN ('FILE')
ORDER BY id;
-- 23 DNI (42 DNI RL)
-- 44 NIF societat
-- 49 sexe
-- 21 D.Naix (40 D.Naix RL)
------
-- 18-20 Nom (63-65 Nom RL)
-- 33 Raó social
------
-- 46 Tipus emp
-- 47 Mida emp
-- 48 Codi classif emp
-- 60 CNAE

SELECT
	count(*) AS num
FROM
	api_voucher av
WHERE
	parent_id IS NULL
	AND campaign_id = 2
	AND status <> 'REFUNDED'
	AND assignee_id IN (SELECT mcu.idcyclos FROM mv_cyclos_users mcu WHERE status = 'ACTIVE');


-- Listat d'adreces del tmp_CHEATERS / tmp_WORKERS
CREATE TABLE tmp_white_workers AS(		  
 SELECT u.id, u.username, u.status, string_agg(ucfv1.string_value, ', ')
	FROM
		cyclos_users u
		LEFT OUTER JOIN cyclos_user_custom_field_values ucfv1 ON (ucfv1.owner_id = u.id)
	WHERE
		u.network_id = 2
		AND u.id IN (...)
		AND ucfv1.field_id IN (77, 78, 79, 80)
	GROUP BY u.id, username, status
	ORDER BY u.id);

INSERT INTO tmp_white_cheaters ( SELECT u.id, u.username, u.status, string_agg(ucfv1.string_value, ', ')
	FROM
		cyclos_users u
		LEFT OUTER JOIN cyclos_user_custom_field_values ucfv1 ON (ucfv1.owner_id = u.id)
	WHERE
		u.network_id = 2
		AND u.id IN (1771,2692,2460,3550)
	GROUP BY u.id, username, status);

-- Llistat dels usuaris que es mereixen recomprar bons 2020
SELECT txu.status, txu.name, txu.username, preu, num, IMPORT, "inc %" || ' %' AS "inc %"
FROM 
  ( SELECT
		assignee_id,
		sum(price) AS preu,
		CEILING(sum(price)/ 25) AS num,
		CEILING(sum(price)/ 25)* 25 AS IMPORT,
		floor(((CEILING(sum(price)/ 25)* 25 / sum(price))-1)* 100) AS "inc %"
	FROM
		( SELECT
				v.id, v.assignee_id, v.status, v.price, v.amount, v.campaign_id
			FROM
				api_voucher v
			LEFT JOIN api_voucher_campaign c ON v.campaign_id = c.id
			WHERE
				v.campaign_id = 1
				AND v.status = 'REFUNDED'
				AND v.refund_date >= c.end_date
			ORDER BY
				assignee_id
		) my_vouchers
	GROUP BY
		assignee_id
) bons2020, mv_cyclos_users txu
WHERE 
      assignee_id = txu.idcyclos
  AND status = 'ACTIVE'
ORDER BY "inc %", preu, username;

REFRESH MATERIALIZED VIEW mv_cyclos_users;   
SELECT * FROM mv_cyclos_users ORDER BY id NULLS LAST LIMIT 200;

SELECT cu."name", cucfv2.*
FROM cyclos_users cu 
		LEFT OUTER JOIN cyclos_user_custom_field_values cucfv2 ON (cucfv2.owner_id = cu.id AND cucfv2.field_id = 49)
WHERE
    network_id = 2 AND
	field_id = 49;

-- 23 DNI (42 DNI RL)
-- 44 NIF societat
-- 49 sexe
-- 21 D.Naix (40 D.Naix RL)
------
-- 18-20 Nom (63-65 Nom RL)
-- 33 Raó social
------
-- 46 Tipus emp
-- 47 Mida emp
-- 48 Codi classif emp
-- 60 CNAE


/*CREATE TABLE tmp_delta (
	id bigserial NOT NULL,
	"comment" varchar(255) NULL,
	quantity int4 NOT NULL,
	reason varchar(255) NULL,
	"timestamp" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	user_id int8 NOT NULL,
	campaign_id int8 NOT NULL,
	quota_id int8 NOT NULL           
);*/

SELECT id FROM voucher_campaign_custom_assignment_delta ORDER BY ID DESC LIMIT 1;
@set delta_id = 000	





/*---------------------------------------------------------------
-- Llista dels que haurien d'estar a la llista negra pq NO viuen a VLD
SELECT cu.id, cu.username, cu."name"
  FROM cyclos_users cu 
 WHERE cu.id NOT IN 
  -- Llista dels VIUEN a Viladecans
 (SELECT u.id 
	FROM
		cyclos_users u
		LEFT OUTER JOIN cyclos_user_custom_field_values ucfv1 ON (ucfv1.owner_id = u.id)
	WHERE
		u.network_id = 2
		AND ucfv1.string_value ~* '08840'
		AND ucfv1.field_id IN (77, 78, 79, 80)
)
--AND (cu.name     ~* 'Cortés' OR cu.username ~* 'Barranco')
;*/

---------------------------------------------------------------
-- Llista dels que haurien d'estar a la llista negra... i ara no hi son (pq treballen a VLD?)
/*SELECT cu.id, lower(cu.username), cu.name, string_agg(ucfv2.string_value, ' ## ') AS city, cu.status
  FROM cyclos_users cu 
  LEFT OUTER JOIN cyclos_user_custom_field_values ucfv2 ON (ucfv2.owner_id = cu.id)
 WHERE cu.id NOT IN 
  -- Llista dels VIUEN a Viladecans
 (SELECT u.id 
	FROM
		cyclos_users u
		LEFT OUTER JOIN cyclos_user_custom_field_values ucfv1 ON (ucfv1.owner_id = u.id)
	WHERE
		u.network_id = 2
		AND ucfv1.string_value ~* '08840'
		AND ucfv1.field_id IN (77, 78, 79, 80)
	) 
AND cu.id NOT IN (SELECT id FROM api_voucher_campaign_user_blacklist avcub) -- Blacklist
AND cu.id NOT IN (SELECT id FROM tmp_white_workers)	-- Han presentat proves de treballar a VLD
AND ucfv2.field_id IN (77, 78, 79, 80)
GROUP BY cu.id, cu.username, cu.name, cu.status 
HAVING string_agg(ucfv2.string_value, ' ## ')~*'vilad'
ORDER BY id ;*/

---------------------------------------------------------------
-- Llista dels que tenen dret a rebre 2 bons (viuen a VLD)
SELECT u.id, idcypher(u.id)
FROM
	cyclos_users u
	LEFT OUTER JOIN cyclos_user_custom_field_values ucfv1 ON (ucfv1.owner_id = u.id)
WHERE
	u.network_id = 2
	AND ucfv1.string_value ~* '08840'
	AND ucfv1.field_id IN (77, 78, 79, 80)
	OR u.id IN (SELECT id FROM tmp_white_workers);


---------------------------------------------------------------
-- Veure dades d'adreça d'un usuari
SELECT owner_id, field_id, string_value
  FROM cyclos_user_custom_field_values
 WHERE owner_id IN (132,497) AND field_id IN (77, 78, 79, 80)
 ORDER BY owner_id, field_id ;


---------------------------------------------------------------
-- Cerca usuari per nom/usuari
SELECT id, username, "name" FROM cyclos_users cu
WHERE (cu.name ~* 'Barranco'
  OR cu.username ~* 'Anapg85')
 ORDER BY "name" ;
