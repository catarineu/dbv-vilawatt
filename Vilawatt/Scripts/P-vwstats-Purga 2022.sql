WITH tot AS (
  WITH tall AS (
	WITH tcubi AS (
	 	 SELECT user_id, name, doc_id, creation_date AS created, ede_account_id AS acid, ede_account_type AS actype,
	            round(ede_account_balance::numeric,2) AS ubal FROM tc_ubiquat
	  ), tcaga AS (
	 	 SELECT holder_name AS name, account_type AS actype, created, account_id AS acid, balance AS abal FROM tc_aganea ta
	  ), llog AS (
         SELECT user_id, max(date_time) AS lastlog FROM cyclos_login_history_logs clh GROUP BY user_id 
      )
	SELECT tcubi.user_id uid, tcubi.name AS u_name, tcubi.actype AS u_type, tcubi.acid AS u_id, tcaga.created AS a_crea,
		   tcaga.acid AS a_id, tcaga.actype AS a_type, tcaga.name AS a_name, tcaga.abal, tcubi.ubal,
		   mcu."name" AS cu_name, mcu.status AS cu_status, tcubi.user_id, llog.lastlog, mcu.username, doc_id,
		   COALESCE((td.estat='E'),FALSE) AS dni,
		   COALESCE((tp.estat='E' OR tp.estat='EE'),FALSE) AS telf,
		   COALESCE((tc.estat='E' OR tc.estat='PE'),FALSE) AS cogn,
		   COALESCE(tf.per_esborrar,FALSE) AS flag
	  FROM tcubi
	       FULL OUTER JOIN tcaga ON (tcubi.acid=tcaga.acid)
	       FULL OUTER JOIN llog  ON (tcubi.user_id=llog.user_id)
	       LEFT OUTER JOIN mv_cyclos_users mcu ON (tcubi.user_id=mcu.id)
	       LEFT OUTER JOIN te_dni  td ON (mcu.id=td.id2::bigint)
	       LEFT OUTER JOIN te_dup  tp ON (mcu.id=tp.id2::bigint)
	       LEFT OUTER JOIN te_cog  tc ON (mcu.id=tc.id2::bigint)
	       LEFT OUTER JOIN te_flag tf ON (mcu.id=tf.id2::bigint)
	)
SELECT  uid, u_name, username, u_type, u_id, -- ubal, abal,
		a_id, cu_status, lastlog, a_crea, COALESCE(ubal,0) AS ubal, REPLACE(abal,',','.')::float AS abal,
		(dni OR telf OR cogn OR flag) AS r_del,
		COALESCE(lastlog>='2023-02-01',FALSE) AS post_b22,
		COALESCE(lastlog>='2022-11-15' AND lastlog<'2023-02-01',FALSE) AS b22,
		COALESCE(lastlog<'2022-11-15', FALSE) AS pre_b22,
		dni, telf, cogn, flag, doc_id
  FROM tall ta
), saldos AS (
	SELECT user_id, sum(COALESCE(ede_account_balance,0)) AS saldo FROM tc_ubiquat tu GROUP BY user_id ORDER BY user_id
)
 SELECT '-' AS ACTION, r_del, pre_b22, b22, post_b22, status,
 		uid, tot.username, a_id, doc_id, u_name,
	    CASE WHEN sal.saldo>0 THEN 1 ELSE 0 END AS ss, sal.saldo
-- 		INTO tmp_purgat_2023 
   FROM tot
        LEFT OUTER JOIN mv_cyclos_users mcu ON (tot.uid=mcu.id)
        LEFT OUTER JOIN saldos sal ON (sal.user_id=tot.uid)
  WHERE a_id IS NOT NULL -- Per esborrar (i potser donar de baixa com usuaris, no?)
        AND mcu.grup='Particulars'
ORDER BY r_del, post_b22, b22, pre_b22;

--========
--  Per si cal refer la taula
--
--DROP TABLE tmp_purgat_2023 ;

SELECT * FROM tmp_purgat_2023;

--================================================================================================
--== MARCATGE ===========================================================================
UPDATE tmp_purgat_2023 SET ACTION='DELETE'  WHERE ss=0;
UPDATE tmp_purgat_2023 SET ACTION='OK'      WHERE ss=0 AND r_del=FALSE AND (b22=TRUE OR post_b22=TRUE) AND status='ACTIVE';

UPDATE tmp_purgat_2023 SET ACTION='RESOLVE' WHERE ss=1;
UPDATE tmp_purgat_2023 SET ACTION='OK'      WHERE ss=1 AND r_del=FALSE AND (b22=TRUE OR post_b22=TRUE) AND status='ACTIVE';

-- 2023-12-15: Han comprat bons perquè no tenien el compte bloquejat, tot i no ser OK
UPDATE tmp_purgat_2023 SET ACTION='OK-2'      
 WHERE uid IN (3542,1264,740,3808,5124,2348,4851,3684,3154,4852,2920,2920);


--================================================================================================
--== LLISTAT CSV JAUME ===========================================================================
SELECT DISTINCT ACTION, r_del, pre_b22, b22, post_b22, count(*), status, ss,
	   sum(saldo),
	   string_agg(DISTINCT uid||':'||username, '; ' ORDER BY uid||':'||username)
 INTO tmp_oficial_purgat_cyclos
 FROM tmp_purgat_2023  
WHERE ACTION='DELETE'
GROUP BY ACTION, r_del, post_b22, b22, pre_b22, ss, status
ORDER BY ss, r_del, post_b22, b22, pre_b22, status;

--================================================================================================
--== LLISTAT AGANEA ==============================================================================
SELECT ACTION, r_del, pre_b22, b22, post_b22, status, doc_id, u_name, saldo, a_id AS cuenta
  INTO tmp_oficial_purgat_aganea
  FROM tmp_purgat_2023  
 WHERE ACTION='DELETE'
ORDER BY saldo DESC, r_del, post_b22, b22, pre_b22, status;


--================================================================================================
--== LLISTAT USUARIS BONS=========================================================================
SELECT DISTINCT ACTION, r_del, pre_b22, b22, post_b22, status, doc_id, u_name
  FROM tmp_purgat_2023  
 WHERE ACTION='OK'
ORDER BY r_del, post_b22, b22, pre_b22, status;

--================================================================================================
--== RESUM PURGAT 2023 ===========================================================================
SELECT ACTION, count(*)
  FROM tmp_purgat_2023  
GROUP BY action
ORDER BY action

--REFRESH MATERIALIZED VIEW mv_cyclos_users ;

--================================================================================================
-- Ultims DELTA arreglats
SELECT avccad.campaign_id || ' - ' || avc."name" AS campaign,
	   quota_id || ' - ' || avcq."name" AS quota, hidden,
	   comment, avccad.quantity, reason, timestamp, user_id 
  FROM api_voucher_campaign_custom_assignment_delta avccad
       LEFT OUTER JOIN api_voucher_campaign avc  ON (avccad.campaign_id=avc.id)
       LEFT OUTER JOIN api_voucher_campaign_quota avcq ON (avccad.quota_id=avcq.id AND avccad.campaign_id=avcq.campaign_id)
 WHERE "timestamp" >= '2023-11-01'
 ORDER BY "timestamp" DESC 
 
-- Ultims DELTA amb detall
SELECT iddecypher(user_id) AS user, mcu.name, avccad.*
  FROM api_voucher_campaign_custom_assignment_delta avccad
       LEFT OUTER JOIN mv_cyclos_users mcu ON mcu.id=iddecypher(user_id)
 WHERE "timestamp" >= '2023-11-01'
   AND user_id IN (-5646242751872640337, 7035893798802676405);
   
-- DELTA arreglats per USUARI
SELECT iddecypher(user_id), campaign_id , quota_id, reason, sum(quantity)
  FROM api_voucher_campaign_custom_assignment_delta avccad
--       LEFT OUTER JOIN mv_cyclos_users mcu ON mcu.id=iddecypher(user_id)
 WHERE "timestamp" >= '2023-11-01'
   AND campaign_id IN (4,5,6)
 GROUP BY user_id, campaign_id, quota_id, reason
HAVING sum(quantity)>1
 ORDER BY sum(quantity) DESC 


--INSERT INTO api_voucher_campaign_custom_assignment_delta
--		("comment",quantity,reason,user_id,campaign_id,quota_id,hidden);
--(
--SELECT 
--	 'Bo comerç #1: Correcció error doble bo', -1, 'BC2023#1', user_id, 4,8,false    
--    FROM api_voucher_campaign_custom_assignment
--WHERE campaign_id = 4
--    AND quantity=2 AND spent < 2
--)
------------
--INSERT INTO api_voucher_campaign_custom_assignment_delta
--		("comment",quantity,reason,user_id,campaign_id,quota_id,hidden);
--(
--SELECT 
--	 'Bo restauració #1: Correcció error doble bo', -1, 'BR2023#1', user_id, 5,9,false    
--    FROM api_voucher_campaign_custom_assignment
--WHERE campaign_id = 5
--    AND quantity=2 AND spent < 2
--)
------------
--INSERT INTO api_voucher_campaign_custom_assignment_delta
--		("comment",quantity,reason,user_id,campaign_id,quota_id,hidden);
--(
--SELECT 
--	 'Bo comerç #1: Correcció error doble bo TRIGGER', -1, 'BC2023#1', user_id, 4,8,false    
--FROM api_voucher_campaign_custom_assignment
-- WHERE "timestamp" > '2023-12-01'
--   AND user_id IN (SELECT idcypher(uid) FROM tmp_purgat_2023 WHERE ACTION!='OK')
--   AND spent =0
--)    
    
-- ==============================================================================
-- Resum ASSIGNACIÓ DE BONS
-- ==============================================================================
SELECT avcca.campaign_id || ' - ' || avc."name" AS campanya,
	   quota_id    || ' - ' || avcq."name" AS quota, sum(avcca.quantity)    
  FROM api_voucher_campaign_custom_assignment avcca
       LEFT OUTER JOIN api_voucher_campaign avc  ON (avcca.campaign_id =avc.id)     
       LEFT OUTER JOIN api_voucher_campaign_quota avcq ON (avcca.quota_id=avcq.id AND avcca.campaign_id=avcq.campaign_id)
WHERE "timestamp" > '2023-12-01'
GROUP BY campanya, quota
ORDER BY campanya


		   
--=========================================================
-- LLISTA BLANCA de COMERÇOS
--=========================================================
-- DETALL Whilelist per campanya
SELECT voucher_campaign_id || ' - ' || avc."name" AS campanya,
	   mcu.name, mcu.grup, mcu.username, redeemer_user_whitelist
  FROM api_voucher_campaign_redeemer_user_whitelist avcruw
       LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.idcyclos=avcruw.redeemer_user_whitelist)
       LEFT OUTER JOIN api_voucher_campaign avc  ON (avcruw.voucher_campaign_id=avc.id)
WHERE voucher_campaign_id IN (4,5,6)
  AND lower(username)=lower('vilatinta')
ORDER BY voucher_campaign_id, mcu.name;

-- TOTALS Whilelist comerços per campanya
SELECT voucher_campaign_id || ' - ' || avc."name" AS campanya, count(*) 
FROM api_voucher_campaign_redeemer_user_whitelist avcruw
     LEFT OUTER JOIN api_voucher_campaign avc  ON (avcruw.voucher_campaign_id=avc.id)
WHERE voucher_campaign_id IN (4,5,6)
GROUP BY voucher_campaign_id, avc.name
ORDER BY voucher_campaign_id;

-- Addició d'un nou comerç
SELECT * FROM mv_cyclos_users mcu WHERE mcu.username ~*'60208808'; -- ='38493236E' -- username ~* 'ghuedo';
SELECT * FROM mv_cyclos_users mcu WHERE mcu.dni      = '38451446T';
SELECT * FROM mv_cyclos_users mcu WHERE mcu.idcyclos = '-7375625008782910928';


-- =================================================================================
-- Control que 4/5 estan també a 6
-- =================================================================================
@set mycyclosid = 5306511541892405944

SELECT avc.id, avc."name", avcruw.redeemer_user_whitelist, mcu."name", mcu.username
  FROM  api_voucher_campaign_redeemer_user_whitelist avcruw
        LEFT OUTER JOIN api_voucher_campaign avc ON (avc.id=avcruw.voucher_campaign_id)
        LEFT OUTER JOIN mv_cyclos_users mcu ON (avcruw.redeemer_user_whitelist=mcu.idcyclos)
 WHERE redeemer_user_whitelist = ${mycyclosid}
 ORDER BY avc.id;

INSERT INTO api_voucher_campaign_redeemer_user_whitelist VALUES (4, ${mycyclosid});
INSERT INTO api_voucher_campaign_redeemer_user_whitelist VALUES (6, ${mycyclosid});

-- Control 
SELECT avcruw.redeemer_user_whitelist, count(*), string_agg(''||voucher_campaign_id, ',') AS campaign, mcu.username, mcu."name", mcu.status
  FROM  api_voucher_campaign_redeemer_user_whitelist avcruw
        LEFT OUTER JOIN mv_cyclos_users mcu ON (redeemer_user_whitelist=mcu.idcyclos)
 WHERE avcruw.voucher_campaign_id IN (4,5,6) 
 GROUP BY avcruw.redeemer_user_whitelist, mcu.username, mcu."name", mcu.status
 HAVING count(*) < 2
 ORDER BY campaign


--DELETE FROM api_voucher_campaign_redeemer_user_whitelist
--WHERE voucher_campaign_id=4
--  AND redeemer_user_whitelist=8765276055712946914;

--SELECT voucher_campaign_id, redeemer_user_whitelist, count(*) 
--FROM api_voucher_campaign_redeemer_user_whitelist avcruw
--WHERE voucher_campaign_id IN (4,5,6)
--GROUP BY voucher_campaign_id, redeemer_user_whitelist
--HAVING count(*)>1 


--=========================================================
--=========================================================
SELECT * FROM mv_cyclos_users mcu WHERE telef = '667013462';
SELECT * FROM tmp_purgat_2023 tp  WHERE username IN ('emorenom', 'tmateos');

--=========================================================
--=========================================================

SELECT u.id, idcypher(u.id)
FROM cyclos_users u
     LEFT OUTER JOIN tmp_purgat_2023 tmp ON (tmp.uid=u.id)
WHERE tmp.action='OK'
  AND u.network_id = 2
    AND u.id IN (
        (   SELECT owner_id
            FROM cyclos_user_custom_field_values ucfv1
            WHERE ucfv1.owner_id = u.id
                AND ucfv1.string_value ~* '08840'
                AND ucfv1.field_id IN (77, 78, 79, 80))         -- Viuen a VLD
    UNION
    ( SELECT id FROM tmp_white_workers))


-- ================
SELECT event_type, count(*)
FROM api_voucher_event_log avel
WHERE "timestamp" > '2023-12-01'
GROUP BY event_type;

SELECT *
FROM api_voucher_event_log avel
WHERE "timestamp" < '2023-01-01'
ORDER BY "timestamp" DESC;




--====================================================================
-- Bons Comerç      :  Campanya 4, Quota  8
--====================================================================
INSERT INTO api_voucher_campaign_custom_assignment_delta
		("comment",quantity,reason,user_id,campaign_id,quota_id,hidden)
(SELECT DISTINCT
	 'Bo comerç #1: Per domicili/treball a Viladecans', 1, 'BC2023#1', idcypher(u.id),4,8,false
FROM cyclos_users u
     LEFT OUTER JOIN tmp_purgat_2023 tmp ON (tmp.uid=u.id)
WHERE (tmp.action='OK' OR tmp.ACTION=NULL) -- Particulars.purgat_OK + Autonoms/empreses.cyclos_ACTIVE
  AND u.status='ACTIVE'
  AND u.network_id = 2
    AND u.id IN (
        (   SELECT owner_id
            FROM cyclos_user_custom_field_values ucfv1
            WHERE ucfv1.owner_id = u.id
                AND ucfv1.string_value ~* '08840'
                AND ucfv1.field_id IN (77, 78, 79, 80))         -- Viuen a VLD
    UNION
    ( SELECT id FROM tmp_white_workers)));     -- Treballen a VLD
       
-- Assignació discrecional del bo comerç
INSERT INTO api_voucher_campaign_custom_assignment_delta
		("comment",quantity,reason,user_id,campaign_id,quota_id,hidden)
VALUES ('Bo comerç #1: Per compensació de BR inútil', 1, 'BC2023#99', 1271286275768441493,4,8,FALSE);
  
    
    
--====================================================================
-- Bons Restauranció:  Campanya 5, Quota  9
--====================================================================
INSERT INTO api_voucher_campaign_custom_assignment_delta
		("comment",quantity,reason,user_id,campaign_id,quota_id,hidden)
(SELECT DISTINCT
	 'Bo restauració #1: Per domicili/treball a Viladecans', 1, 'BR2023#1', idcypher(u.id),5,9,false
FROM cyclos_users u
     LEFT OUTER JOIN tmp_purgat_2023 tmp ON (tmp.uid=u.id)
WHERE (tmp.action='OK' OR tmp.ACTION=NULL) -- Particulars.purgat_OK + Autonoms/empreses.cyclos_ACTIVE
  AND u.status='ACTIVE'
  AND u.network_id = 2
    AND u.id IN (
        (   SELECT owner_id
            FROM cyclos_user_custom_field_values ucfv1
            WHERE ucfv1.owner_id = u.id
                AND ucfv1.string_value ~* '08840'
                AND ucfv1.field_id IN (77, 78, 79, 80))         -- Viuen a VLD
    UNION
    ( SELECT id FROM tmp_white_workers)));     -- Treballen a VLD
    

--====================================================================
-- Bons Verds       :  Campanya 6, Quota 10
--====================================================================

@set mydni = '35057174E'
SELECT idcyclos, username, email, id, status, name, dni FROM mv_cyclos_users mcu WHERE upper(mcu.dni)=${mydni}; -- username ='alejandrotr8'

@set mycyclosid = 1847747028071864912
SELECT user_id, campaign_id, quantity , "timestamp"
  FROM api_voucher_campaign_custom_assignment avcca 
 WHERE user_id = ${mycyclosid}
   AND timestamp > '2023-12-01'
 ORDER BY campaign_id ;

-- 3. Assignació del bo verd
INSERT INTO api_voucher_campaign_custom_assignment_delta
		("comment",quantity,reason,user_id,campaign_id,quota_id,hidden)
VALUES ('Bo verd #1: Per validació OK', 1, 'BV2023#1', ${mycyclosid},6,10,FALSE);


-- EXTRA: Llistat agrupat de tots els usuaris amb bons assignats
SELECT max("timestamp"), reason, COMMENT, sum(quantity), mcu.username, mcu.name
  FROM api_voucher_campaign_custom_assignment_delta avccad
  	   LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.idcyclos=avccad.user_id)
 WHERE reason='BV2023#1'
 GROUP BY GROUPING SETS ((reason, COMMENT, mcu.username, mcu.name),())
 ORDER BY username;

-- EXTRA: Llistat detall de tots els usuaris amb bons assignats
SELECT "timestamp", reason, COMMENT, quantity, mcu.username, mcu.name
  FROM api_voucher_campaign_custom_assignment_delta avccad
  	   LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.idcyclos=avccad.user_id)
 WHERE reason='BV2023#1'
 ORDER BY "timestamp" DESC;


--=========================================================
-- MONITORING Bons
--=========================================================
WITH comprats AS (
					SELECT campaign_id, sum(spent) AS venuts
					  FROM api_voucher_campaign_custom_assignment avcca
					 WHERE campaign_id IN (4, 5, 6)
					   AND quantity > 0
					   AND spent > 0
					 GROUP BY campaign_id
					 ORDER BY campaign_id NULLS LAST),
     oferts AS (
					SELECT id AS campaign_id, name, total_issuable_number AS oferts, total_issuable_number_limit AS oferts_limit
					  FROM api_voucher_campaign avc
					 WHERE id IN (4, 5, 6)
					)
SELECT o.campaign_id ||' - '|| o.name AS campanya, 
       COALESCE(sum(c.venuts),0)       AS venuts,
       COALESCE(sum(o.oferts),0)       AS oferts,
	   COALESCE(sum(o.oferts_limit),0) AS oferts_limit,
	   COALESCE(sum(o.oferts_limit),0)-COALESCE(sum(c.venuts),0) AS romanents,
	   (COALESCE(sum(c.venuts),0) / COALESCE(sum(o.oferts_limit),0) * 100)::integer AS ratio
  FROM comprats c
       FULL OUTER JOIN oferts o ON (c.campaign_id=o.campaign_id)
GROUP BY GROUPING SETS ((o.campaign_id, o.name),())
ORDER BY o.campaign_id


	 
--================================================================================================
--================================================================================================
-->>>> Comptes a ESBORRAR segons LAST_LOGIN
SELECT uid, u_name, username, u_type, u_id, -- ubal, abal,
    a_id, cu_status, lastlog, a_crea, COALESCE(ubal, 0) AS ubal, REPLACE(abal, ',', '.')::float AS abal, (dni
        OR telf
        OR cogn
        OR flag) AS r_del, COALESCE(lastlog >= '2023-01-01', FALSE) AS jan23, COALESCE(lastlog >= '2022-07-01'
        AND lastlog < '2023-01-01', FALSE) AS jul22, lastlog < '2022-07-01' AS pre22mai, dni, telf, cogn, flag
FROM tall ta
    SELECT extract(MONTH FROM a_crea::date) AS month, r_del, pre22mai, jul22, jan23, count(*)
    --,string_agg(COALESCE(lastlog::varchar,'*'),',') AS last_log
    --,string_agg(COALESCE(tot.username,'*'),',') AS unames
FROM tot
    LEFT OUTER JOIN mv_cyclos_users mcu ON (tot.uid = mcu.id)
WHERE a_id IS NOT NULL -- Per esborrar (i potser donar de baixa com usuaris, no?)
    --        AND mcu.grup='Particulars'
    --GROUP BY  ROLLUP(extract(MONTH FROM a_crea::date), r_del, dead)
GROUP BY extract(MONTH FROM a_crea::date), r_del, pre22mai, jul22, jan23
ORDER BY extract(MONTH FROM a_crea::date), r_del, pre22mai, jul22, jan23;

CREATE TABLE tc_ubiquat AS (
    SELECT *
    FROM tc_ubiquat2 LIMIT 1
);

SELECT count(*), status,
FROM mv_cyclos_users
GROUP BY status;

--REFRESH MATERIALIZED VIEW mv_cyclos_users;
SELECT *
FROM mv_cyclos_users
LIMIT 3;
 

SELECT * FROM tmp_rest4all WHERE name~*'sambl';

-----------------------------------------
-- PREGUNTES A RESOLDRE -- Usuari 277 ANA MARIA GINES LAFUENTE === Demanar a Aganea que esborri 8a858e76707b7bd701707bfabad73381
 WHERE u_id IS NULL AND a_id IS NOT NULL            -- Per què Aganea té un compte i nosaltres no?
 ORDER BY u_id;
 
--------
-- 569 ACCEPTANTS → Passar saldo a TITULAR + ser esborrades ==> email

-----------
-- >> LAURA === Mail d'avis + baixa als 3 dies
 WHERE cu_status<>'ACTIVE' AND NOT r_del AND a_id IS NOT NULL -- Per què no esborrem el compte si NO està actiu?
 ORDER BY u_name, u_type, u_id;

-----------
-- >> AJUNTAMENT
 WHERE dead AND NOT r_del AND A_ID IS NOT NULL    -- Per què no esborrem el compte si NO està actiu fa més d'un any?
 ORDER BY u_name, u_type, u_id;

----> Ok, són de DESEMBRE'22
 WHERE u_id IS NOT NULL AND a_id IS NULL AND u_type='CUENTA_TITULAR'       -- Per què tenim compte i Aganea no sent CUENTA_TITULAR?
 ORDER BY cu_status, u_name, u_type, u_id;

----> Pel saldo > 0
WHERE u_id IS NOT NULL AND a_id IS NOT NULL AND u_type='CUENTA_ACEPTANTE' -- Per què tenim compte de CUENTAS_ACEPTANTES?
 ORDER BY cu_status, u_name, u_type, u_id;

-----------------------------------------
-- COMPTES A ESBORRAR
 WHERE (r_del OR dead) AND a_id IS NOT NULL -- Per esborrar (i potser donar de baixa com usuaris, no?)
 ORDER BY u_name, u_type, u_id;

 WHERE NOT (r_del OR dead) AND a_crea < '2022-01-01' AND u_type='CUENTA_TITULAR' AND a_id IS NOT NULL -- Per renovar
 ORDER BY u_type, u_name, u_type, u_id;



---------------------------------------------------
SELECT id2 FROM te_dni WHERE estat IN ('E');
SELECT id2 FROM te_dup WHERE estat IN ('E','EE');
SELECT id2 FROM te_cog WHERE estat IN ('E','PE');
SELECT id2 FROM te_flag WHERE per_esborrar IS TRUE;
---------------------------------------------------
-- Creació de taula te_flag
DROP TABLE te_flag;
CREATE VIEW te_flag AS SELECT
	u.username, u.status, ucfv.boolean_value AS per_esborrar, u.id AS id2, idcypher(u.id) AS id2c
FROM 
    cyclos_users u 
	LEFT OUTER JOIN cyclos_user_custom_field_values  ucfv on (ucfv.owner_id=u.id)
WHERE 
    u.network_id =2 -- Vilawatt live
	AND ucfv.field_id=88

---------------------------------------------------
-- Llista de camps personalitzats
select
	u.username, u.status, u."name", u.email, u.user_activation_date, ucf.id, ucf."name" as camp,
	coalesce(ucfv.string_value,'') || coalesce(case when ucfv.boolean_value is null then '' when ucfv.boolean_value then '<true>' else '<false>' end,'') ||
	coalesce(ucfv.date_value::date::varchar,'') || coalesce(ucfv.decimal_value::varchar,'') as valor
from
	cyclos_users u 
	left outer join cyclos_user_custom_field_values  ucfv on (ucfv.owner_id=u.id)
	left outer join cyclos_user_custom_fields ucf on (ucf.id=ucfv.field_id)
where
	u.network_id =2 -- Vilawatt live
	and u.user_activation_date between '2022-04-01' and '2022-05-01'
	and u.id=4928
order by 
	ucfv.date_value, username, id;

---------------------------------------------------
SELECT id2 FROM te_dni WHERE estat IN ('E');
SELECT id2 FROM te_dup WHERE estat IN ('E','EE');
SELECT id2 FROM te_cog WHERE estat IN ('E','PE');
SELECT id2 FROM te_flag WHERE per_esborrar IS TRUE;

SELECT * FROM te_cog ;

UPDATE te_cog
   SET id2=mcu.id, id2c=mcu.idcyclos
  FROM mv_cyclos_users mcu
 WHERE mcu.idcyclos=te_cog.id::bigint

 UPDATE te_cog
   SET estat='E'
 WHERE estat='ESBORRAR';

SELECT estat, count(*)
FROM te_cog tc GROUP BY estat;

SELECT *
  FROM mv_cyclos_users mcu
 WHERE mcu.username='gamahdigital'


SELECT estat, count(*) 
 FROM te_dup td
GROUP BY estat;



SELECT mcu.username, "name", dni, telef, mcu.status, action
  FROM mv_cyclos_users mcu
       LEFT OUTER JOIN tmp_purgat_2023 tp ON (lower(tp.username)=lower(mcu.username))
 WHERE mcu.status = 'ACTIVE' 
   AND ACTION IS NULL OR ACTION IN ('OK', 'OK-2') 
   AND mcu.idcyclos IN 
   		(SELECT user_id 
   		   FROM api_voucher_campaign_custom_assignment 
   		  WHERE timestamp>='2023-12-01' 
   		    AND campaign_id = 6
   		    AND spent < quantity)
ORDER BY ACTION DESC, mcu.username 


SELECT * FROM api_voucher_campaign_custom_assignment LIMIT 3;











