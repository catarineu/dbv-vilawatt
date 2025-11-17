--====================================================================
-- Llista blanca (nòmina)
--====================================================================
WITH 
  maxims AS (
	SELECT dni, max(creation_date) AS maxdate
	  FROM mv_cyclos_users mcu
	 GROUP BY dni 
	 ORDER BY max(creation_date) DESC 
   )
	SELECT maxims.dni, maxdate, mcu.dni, mcu.status 
	  FROM maxims
	       LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.dni = maxims.dni AND mcu.creation_date = maxims.maxdate);
	       
-- REFRESH MATERIALIZED VIEW mv_cyclos_users ;


-- Jaume 1847747028071865081 -   24
-- Joan  7612354551106099768 - 6198
 

SELECT id, username, status, idcyclos FROM mv_cyclos_users mcu WHERE dni='45125908T';

@set myuser = 694825523465017916

SELECT idcyclos, mcu.id, mcu.username, email, status, tww.*
  FROM mv_cyclos_users mcu 
       LEFT OUTER JOIN tmp_white_workers tww ON (tww.id=mcu.id)
 WHERE idcyclos = ${myuser};

-- Control d'adreça
SELECT ucfv1.string_value
  FROM cyclos_user_custom_field_values ucfv1
 WHERE ucfv1.owner_id = iddecypher(${myuser})
   AND ucfv1.field_id IN (77, 78, 79, 80);
                
SELECT id, username, status, idcyclos FROM mv_cyclos_users mcu WHERE idcyclos = ${myuser};
INSERT INTO tmp_white_workers VALUES (6330, 'marinafeito', 'Treballa a Viladecans');
 

--====================================================================
-- Reactivació d'USUARIS
--====================================================================
-- 1. Consulta del codi d'usuari 

@set mydni = '53314604Y'
SELECT * FROM tmp_purgat_2023 tp WHERE upper(doc_id) IN (${mydni});

SELECT idcyclos, username, email, id, status, name  FROM mv_cyclos_users mcu WHERE mcu.dni=${mydni};

-- 2A. Consulta quins bons té assignats
SELECT "timestamp", reason, COMMENT, quantity AS num, mcu.username, mcu.name
  FROM api_voucher_campaign_custom_assignment_delta avccad
  	   LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.idcyclos=avccad.user_id)
 WHERE user_id IN (SELECT  idcyclos FROM mv_cyclos_users mcu2 WHERE dni=${mydni})
   AND "timestamp" >= '2023-10-01'
 ORDER BY "timestamp" DESC   

-- 2B. Consulta bons assignats/comprats
 -- Que ha gastat un usuari
SELECT user_id AS idcyclos, iddecypher(user_id) AS id,campaign_id, quota_id, quantity, spent 
FROM api_voucher_campaign_custom_assignment
WHERE campaign_id IN (4, 5, 6)
  AND user_id IN (SELECT idcyclos FROM mv_cyclos_users mcu WHERE upper(dni)=upper(${mydni})) 
  
-- 2C. Comptes EDE bons
SELECT tp.status AS p_status, ACTION, mcu.status, r_del, mcu.* 
  FROM mv_cyclos_users mcu
  LEFT OUTER JOIN tmp_purgat_2023 tp ON upper(tp.a_id)=upper(mcu.dni)
 WHERE upper(dni)=${mydni}
  

-- =================================================================================
-- 10. Taula general reactivats
SELECT DISTINCT tpr.COMMENT, tp.ACTION, mcu.status, tpr.dni, tpr.moment,  tp.r_del, pre_b22, b22, post_b22, uid, tp.username, u_name, ss, tp.saldo
  FROM tmp_purgat_2023_reactivats tpr
       LEFT OUTER JOIN tmp_purgat_2023 tp ON (lower(tp.doc_id)=lower(tpr.dni))
       LEFT OUTER JOIN mv_cyclos_users mcu ON (lower(mcu.dni)=lower(tpr.dni))
 WHERE tpr.dni=${mydni} 
 ORDER BY ACTION, status, dni;

-- 11. Nou reactivat
INSERT INTO tmp_purgat_2023_reactivats (dni, comment) VALUES (${mydni}, 'Ha comprat bons');

UPDATE tmp_purgat_2023 
   SET ACTION='OK'
 WHERE upper(doc_id) = ${mydni};

-- 12. Validació final
SELECT * FROM tmp_purgat_2023            WHERE upper(doc_id) = ${mydni};
SELECT * FROM tmp_purgat_2023_reactivats WHERE upper(dni)    = ${mydni};


-- Tenen assignació, han comprat i NO HAURIEN DE TENIR ASSIGNACIÓ
--SELECT *
--  FROM tmp_purgat_2023 
--	 WHERE uid IN ( 
--		 SELECT iddecypher(user_id)
--		FROM api_voucher_campaign_custom_assignment
--		 WHERE "timestamp" > '2023-12-01'
--		   AND user_id IN (SELECT idcypher(uid) FROM tmp_purgat_2023 WHERE ACTION!='OK')
--		   AND spent >0
--		   )


-- Reactivo els reactivats ========================
--UPDATE tmp_purgat_2023 SET ACTION='OK'
--  WHERE upper(doc_id) IN (SELECT upper(dni) FROM tmp_purgat_2023_reactivats WHERE COMMENT='OK');

SELECT * FROM tmp_purgat_2023_reactivats ;

-- SELECT upper(dni) FROM tmp_purgat_2023_reactivats WHERE COMMENT='OK';