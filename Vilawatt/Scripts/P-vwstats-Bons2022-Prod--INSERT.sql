SELECT email, "name", creation_date, * 
FROM mv_cyclos_users mcu 
ORDER BY creation_date DESC;

REFRESH MATERIALIZED VIEW mv_cyclos_users;
REFRESH MATERIALIZED VIEW mv_bonusers_prod;
REFRESH MATERIALIZED VIEW mv_payments;

SELECT user_id, cu.id, cu."name", sum(quantity), reason
  FROM  api_voucher_campaign_custom_assignment_delta
  	    LEFT OUTER JOIN cyclos_users cu ON cu.id=iddecypher(user_id)
 WHERE "timestamp" >= '2024-12-01'
   AND campaign_id >= 7
 GROUP BY reason, user_id, cu.id, cu."name";

SELECT user_id, cu.id, cu."name", quantity, reason, campaign_id , quota_id 
  FROM  api_voucher_campaign_custom_assignment_delta
  	    LEFT OUTER JOIN cyclos_users cu ON cu.id=iddecypher(user_id)
 WHERE "timestamp" >= '2024-12-01'
   AND campaign_id >= 7 LIMIT 200;

-- ====================================================================
-- ====================================================================

SELECT * FROM cyclos_users cu WHERE name~*'jaume';

CALL cron_bons12();

INSERT INTO api_voucher_campaign_custom_assignment_delta
       (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
VALUES ('Test 2', 1, 'Bo Text', now(), idcypher(24), 8, 12, true);

-- --------------------------------------
-- Pendent de comprar
SELECT
--	avel.timestamp, avel.event_type, --'ASSIGNED', 'REDEEMED', 'REFUNDED'
	av.campaign_id, avc."name",
	avc.total_issuable_number_limit AS MAXbons, count(*) AS venuts, 
	avc.total_issuable_number_limit - count(*) AS pendents, 
	(1000*(avc.total_issuable_number_limit - count(*)) / avc.total_issuable_number_limit)::float/10 AS "pendents%",
	sum(av.amount),
	2*avc.total_bonus_amount_limit - sum(av.amount) AS difi, avel.event_type
FROM
	api_voucher_event_log avel
	LEFT OUTER JOIN api_voucher av ON (avel.voucher_id=av.id)
	LEFT OUTER JOIN api_voucher_campaign avc ON (avc.id=av.campaign_id)
WHERE 
	avel.event_type IN ('ASSIGNED', 'REFUNDED')
	AND av.campaign_id >= 7
--	AND "timestamp" >= '2022-01-01'
GROUP BY GROUPING SETS ((av.campaign_id,  avc."name", avel.event_type, avc.total_issuable_number_limit, avc.total_bonus_amount_limit),())
ORDER BY av.campaign_id;

-- --------------------------------------
-- Pendent de gastar
SELECT
    av.campaign_id, avc."name", avc.suspended, count(*), sum(av.amount),
   	round(100*sum(av.amount) / (2*avc.total_bonus_amount_limit),1) AS "dif%", av.status
FROM
	api_voucher av
	LEFT OUTER JOIN api_voucher_campaign avc ON (avc.id=av.campaign_id)
WHERE 
	av.status IN ('NEW', 'ASSIGNED')
	AND av.campaign_id >= 7
GROUP BY GROUPING SETS ((campaign_id, av.status, avc.suspended, avc."name", total_bonus_amount_limit),())
ORDER BY av.campaign_id;

SELECT * FROM mv_cyclos_users mcu WHERE name ~*'Albaladejo';
	 
-- ====================================================================
-- ====================================================================
SELECT * FROM vw_s1_general(); 

-- ====================================================================
-- ==================================================================== 2024 2024
-- CAMPANYES:  7=Consum,  8=Verds
-- QUOTES   : 11=Consum, 12=Verds

-- ASSIGNACIÓ Bons compensació 2023
--INSERT INTO api_voucher_campaign_custom_assignment_delta
--       (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
--(
--SELECT 'BW2024-reward2023', 2, 'Bo Consum: Compensació per problemes 2023', now(), idcyclos, 7, 11, FALSE
--  FROM mv_cyclos_users mcu WHERE email IN ('pedro.delolmo2808@gmail.com')
--);
--
--  FROM mv_cyclos_users mcu WHERE email IN ('silodaon@hotmail.com','atenea2208@hotmail.com','scortestaranilla@hotmail.com','amymsandor@gmail.com','rubiano869@hotmail.com','silviaosorioperez@gmail.com','piluk26@gmail.com','vprloko@gmail.com','carmenfa34@hotmail.com','susanadfc@hotmail.com',
--'jordanparticular@gmail.com','lolicaay@gmail.com','fuensantapadillapedreno@gmail.com','recycvila@hotmail.com','daniel@miyointerior.com','hugoespinosacampos@gmail.com','ethannaiara@outlook.es','fmvillalba3@gmail.com','lolidibu@gmail.com',
--'andrea.vaquero2004@gmail.com','alarconoptics@gmail.com','judit.atalao@gmail.com','silviaosorioperez@gmail.com','paco-3573@hotmail.es','borrulljoaquim@gmail.com','annabc_7@hotmail.com','carmenpulidosalido@gmail.com','daniel_ruiz_ferrer@hotmail.com',
--'pablocozarreinaldo@gmail.com','anglessalidolopez@gmail.com','juanrtega@hotmail.com','jcarlosborraz@gmail.com','josems100@hotmail.com','mangel7875@gmail.com','lgv1785@gmail.com','nicolaslg77@gmail.com','maite-lopez.m@hotmail.com',
--'lopezsorianomeugenia@gmail.com','carlosvallejo1969@gmail.com','ramonespejo@hotmail.com','wendyestebab@gmail.com','jose_88_sal@hotmail.com','albahh22@gmail.com','ltalave2@xtec.cat','frubio81@gmail.com','hugovalverde9@gmail.com',
--'luciaparronbello88@gmail.com','fernandoalemanrodriguez12@gmail.com','joseprivers@hotmail.com','laiamarmez@gmail.com','comercialdrl@gmail.com','helenita.13.26@gmail.com','atenea2208@hotmail.com','jennifervm_22@hotmail.com',
--'ma.pu.es@gmail.com','emiliros@hotmail.com','sergio1.arribas@gmail.com','rocana26@gmail.com','julimision@hotmail.com','paquimar100@hotmail.com','mnievesprieto@gmail.com','natalicamp@hotmail.com','silviaortegamolina@hotmail.com',
--'prodriguezb3394@gmail.com','crisvila2299@gmail.com','ericpinell1129@gmail.com','valenarjona1605@gmail.com','alcarazsanchez@hotmail.es','txusrubicarreno@gmail.com','marina.gonzalez.mg57@gmail.com','miyolu@msn.com','pilibailach@gmail.com',
--'gpg1988@hotmail.com','fgonzalezrios30@gmail.com','hmartinmartinmoreno@gmail.com','jaume.sacristan@gmail.com','terejordi2@gmail.com','lidia.armengol@gmail.com','edalsa13@gmail.com','sylvias08@hotmail.com','inmad75@gmail.com',
--'jess.dom95@gmail.com','moreno.rosa.cat@gmail.com','rp1971@hotmail.es','monjeaina@gmail.com','jeniterron@gmail.com','mrloli@yahoo.es','albertbuigues@gmail.com','cac_vila@hotmail.com','lopezavalosenrique@gmail.com','mariamonterosamos@gmail.com',
--'olgadlvega@gmail.com','chachovc5@gmail.com','emilio.1967@hotmail.com','antinyolo@hotmail.com','ctajuelo@hotmail.com','aguilera.fermin@gmail.com','daniel.espin.2000@hotmail.com','fmvillalba2@gmail.com','joseantojimenez@hotmail.com',
--'jimenezarteagaadrian@gmail.com','danicaminal@gmail.com','josecamero1@gmail.com','hidalgolopezk@gmail.com','lydia.diaze@gmail.com','mariam.carmona07@gmail.com','juliagarre@hotmail.com','calvovitales@gmail.com','dagaher@icloud.com',
--'euny4b@hotmail.com','susana_andreu@hotmail.com','facturas-valero@hotmail.com',
--'septiembre-159@hotmail.com','marimar.fm26@yahoo.es','gonzalorodriguezaguilar@hotmail.com','meribo2017@gmail.com','vprloko@gmail.com','esther.justes@gmail.com','joan.escribano@gmail.com','blackpryar@gmail.com','merce.carrasco@outlook.com',
--'eva.lara@hotmail.com','sad.alarcon@gmail.com','saharayropa@gmail.com','aliruiz11@hotmail.com','belen.gallardo@hotmail.es','alexandddra@outlook.com','estefi_loce@hotmail.com','sonia4681@hotmail.com','nesi.francisco@gmail.com','anthonio.66@hotmail.com',
--'miguelalmero@gmail.com','s.j.adamson@gmail.com','llopezmaroto@hotmail.com','salasfernandez@gmail.com','susana_1986@hotmail.com','anams81@hotmail.com','benni.23.blp@gmail.com','jean.ruotolo@gmail.com','sanchezcabreramontse@gmail.com',
--'joanna.rivas@gmail.com','oscpad@hotmail.com','lauramorenob@gmail.com','albetb1973@gmail.com','ralcalca8@gmail.com','erika_agfe@hotmail.com','sergibabiano2005@gmail.com','bausasoriano2000@gmail.com','isabellaramonzon@gmail.com',
--'raul922001@gmail.com','lauraraventos79@gmail.com','manoli.ferreira.garcia@gmail.com','fernandez.lucena@yahoo.es','jonaih@hotmail.com','piluk26@gmail.com','vaneskeit@gmail.com','paula27803@gmail.com','veronicarc.vrc@gmail.com',
--'lopezcaleromaricarmen@gmail.com','mireia.bass@gmail.com','josecasares1989@gmail.com','ainarapallerola@gmail.com','javierrg24@gmail.com','angelmolamucho4884@gmail.com','lydiaesparrago@gmail.com','renata.lages@gmail.com',
--'tdominguez1977@gmail.com','raxidelcadi@gmail.com','mja20221@gmail.com','cristina.gonzalez0709@gmail.com')
--AND status='ACTIVE'


SELECT count(*) FROM api_voucher_campaign_custom_assignment_delta WHERE "timestamp" >= '2024-12-18';
UPDATE api_voucher_campaign_custom_assignment_delta SET hidden =TRUE WHERE  "timestamp" >= '2024-12-18';

-- ASSIGNACIÓ Bons Restauració (compra)
IINSERT INTO api_voucher_campaign_custom_assignment_delta
       (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
VALUES ('BW2024 Consum', 1, 'Bo Consum', now(), idcypher(), 7, 11, false)


-- ====================================================================
-- ====================================================================
SELECT * FROM api_voucher_campaign avc 

WITH a AS (
SELECT iddecypher(user_id) AS id, mcu.dni, mcu.username, mcu."name", mcu.email, mcu.telef,
		CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM api_voucher_campaign_custom_assignment_delta d2 
            WHERE d2.user_id = d.user_id 
            AND d2.campaign_id = 8
        ) THEN TRUE 
        ELSE FALSE 
    END AS C23_24, d.quantity
  FROM api_voucher_campaign_custom_assignment_delta d
       LEFT OUTER JOIN mv_cyclos_users mcu ON mcu.idcyclos=user_id 
 WHERE campaign_id = 8
 )
 SELECT id, username, dni,  name, email, telef, c23_24, sum(quantity) AS q
   FROM a 
  GROUP BY id, username, dni, name, email, telef, c23_24
 ORDER BY sum(quantity), C23_24 DESC, name;
 
-- Consulta bons individual
SELECT *
  FROM  api_voucher_campaign_custom_assignment_delta
  WHERE user_id =idcypher(1152)
   AND timestamp > '2024-12-01'
 ORDER BY "timestamp" ;

-- Consulta adreça individual
SELECT *
  FROM cyclos_user_custom_field_values ucfv1 
 WHERE ucfv1.owner_id IN (714, 3841)
   AND ucfv1.string_value ~* '08840'
   AND ucfv1.field_id IN (77, 78, 79, 80)

-- ******************************************************************************************************************
-- ******************************************************************************************************************
-- ******************************************************************************************************************
-- consulta USUARI
REFRESH MATERIALIZED VIEW mv_cyclos_users;
SELECT id, username, name, dni, email, telef, status
  FROM mv_cyclos_users mcu 
-- WHERE name  ~* ('gras');
-- WHERE username  ~* ('hand');
-- WHERE lower(username) IN ('alejandropm','tamdg90','anasereno','dolors','emipg70','robzaro','lauracordoba','carmengarciavcn','emmalopez','josemarchena','jesbautista','rosariomoreno','nilgarcia','aliciamartin','simcapaco')
-- WHERE email   ~* 'anablanquecastro@hotmail.com';
 WHERE upper(dni) in ('52914605T');
-- WHERE upper(dni) in (
-- '38080285J','43529709R','52200706K','52910256K','38510805L','39436835T','46748033G','46773994K',
--'52913286S','53063558M','35057174E','43635631P','46408909S','48471553L','52205808V','52910555K',
--'52918130Y','70731448P','77088203T','35107882S','36570783R','36930395P','38058519M','38375239S',
--'39658513G','47966198C','52208818Z','52915865H','52916523D','53311168C','53318225Q','80143314K',
--'36571838K','38432089D','44175236X','46034735M','46207249L','46240812W','46464152N','46598910J',
--'47651756B','47654976B','47787068Z','52206880P','52911208F','52911385T','52914934F','77100324T',
--'35027505T','35055931K','43549786E','46326186T','46725685N','46747539Q','47603664N','52208618K',
--'52916806Q'
--)
-- WHERE upper(dni) in ('47654976B','47271586P','52914864Y','35082594G','52206880P','52468286L','52913750L','43529709R','52203668Q','46747539Q','32017793E','52918130Y','70731448P',
-- 			'43635631P','52910256K','52911385T','53311168C','52208618K','52209053L','48283170Y','35055931K','46240812W','46356065W','47966198C','55495532M','36930395P','46408909S',
--			'39436835T','38032353J','47966198C','52911170S','53319688F')
--   AND status='ACTIVE' ORDER BY id;
-- WHERE telef = '607627262';



@set mdni  = '52911385T'
@set mbons = 2
SELECT id, ${mbons} bons, ${mdni} AS dni, status FROM mv_cyclos_users mcu WHERE upper(dni) in (${mdni});

---- INSERCIO
WITH who AS (
	SELECT id FROM mv_cyclos_users mcu WHERE upper(dni) in (${mdni}) ORDER BY id  LIMIT 1
),  quant AS (
	SELECT ${mbons}-LEAST(${mbons},COALESCE(sum(d.quantity),0)) AS q
	  FROM api_voucher_campaign_custom_assignment_delta d
	 WHERE user_id=(SELECT idcypher(id) FROM who) AND campaign_id=8
)
INSERT INTO api_voucher_campaign_custom_assignment_delta
       (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
(SELECT 'BW2024 Verd', quant.q, 'Bo Verd', now(), (SELECT idcypher(id) FROM who), 8, 12, FALSE
   FROM quant)
  RETURNING (SELECT id FROM who), quantity;
  
---- CONSULTA
WITH who AS (
	SELECT id FROM mv_cyclos_users mcu
--	 WHERE upper(dni) in (
--  	'35055931K','35057174E','35107882S','36570783R','36930395P','38058519M','38080285J','38375239S','38432089D',
--    '38510805L','39436835T','39658513G','43529709R','43549786E','43635631P','44175236X','46034735M','46207249L','46240812W',
--	'46408909S','46464152N','46747539Q','46748033G','46773994K','46813511R','47651756B','47654976B','47966198C','48283170Y',
--	'48471553L','52200706K','52205808V','52206880P','52208618K','52208818Z','52910256K','52910555K','52911208F','52911385T',
--	'52913286S','52914864Y','52914934F','52915865H','52918130Y','53063558M','53311168C','53318225Q','70731448P','77100324T',
--	'78839019X','80143314K')
	WHERE upper(dni) in (${mdni}) ORDER BY id  LIMIT 1
)
SELECT iddecypher(user_id) AS id, dni,  sum(d.quantity) AS q, mcu.username AS user, mcu."name", campaign_id AS c, d.reason || ' - ' || d."comment" AS tipus
  FROM api_voucher_campaign_custom_assignment_delta d
       LEFT OUTER JOIN mv_cyclos_users mcu ON mcu.idcyclos=user_id 
 WHERE --user_id IN (SELECT idcypher(id) FROM who) AND 
       d."timestamp" >= '2024-12-01'
   AND campaign_id = 8
 GROUP BY GROUPING SETS (
 	(user_id, dni, mcu.username, mcu."name", d.campaign_id, d."comment", d.reason),
 	())
 ORDER BY dni;


   
@set user = 4248
-- ASSIGNACIÓ Bo Verd ========================================
--INSERT INTO api_voucher_campaign_custom_assignment_delta
--       (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
--VALUES ('BW2024 Verd', -1, 'Bo Verd', now(), idcypher(${user}), 8, 12, false)
--RETURNING iddecypher(user_id);

SELECT iddecypher(user_id) AS id, mcu.username AS user, mcu."name", campaign_id AS c, sum(d.quantity) AS q, d.reason || ' - ' || d."comment" AS tipus, d."timestamp", d.hidden
  FROM api_voucher_campaign_custom_assignment_delta d
       LEFT OUTER JOIN mv_cyclos_users mcu ON mcu.idcyclos=user_id 
 WHERE user_id=idcypher(${user})
   AND d."timestamp" >= '2024-12-01'
   AND campaign_id IN (7,8)
 GROUP BY GROUPING SETS ((user_id, mcu.username, mcu."name", d.campaign_id, d."comment", d.reason, d."timestamp", d.hidden), ())
 ORDER BY d."timestamp" DESC ;

SELECT d.reason, d.quantity AS q, d."timestamp", d.user_id, d.campaign_id || '-' || d.quota_id AS cam_quo, d.hidden,
	   mcu.username, mcu."name", mcu.dni, mcu.email, mcu.id 
--SELECT d.*
  FROM api_voucher_campaign_custom_assignment_delta d
       LEFT OUTER JOIN mv_cyclos_users mcu ON mcu.idcyclos=user_id 
 WHERE campaign_id =8
 ORDER BY "timestamp" DESC;


@set user     = 2548
@set username = 'alexcar'
-- HABILITACIÓ USUARI ----------------------------------------
INSERT INTO tmp_white_workers (id, username, descr) VALUES (${user}, ${username}, 'Treballa a Viladecans');
SELECT * FROM tmp_white_workers WHERE ID = ${user};

CALL cron_bons12(); -- Per donar-li bons a l'instant

SELECT * FROM mv_cyclos_users mcu WHERE id =${user};
SELECT * FROM vw_b3_controlvld(${user});    -- Adreça
SELECT * FROM vw_b2_bonsassignats(${user});
SELECT * FROM mv_bonusers_prod mbp WHERE id =${user};

--------------------------------------------------------------------------------
-- HABILITACIÓ COMERÇ ----------------------------------------
@set user     = 2548
INSERT INTO api_voucher_campaign_redeemer_user_whitelist 
(SELECT 8, idcyclos 
   FROM mv_cyclos_users WHERE id =${user}
) ON CONFLICT DO NOTHING;
    
SELECT DISTINCT w.*, mcu.name, mcu.dni 
  FROM api_voucher_campaign_redeemer_user_whitelist w
       LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.idcyclos=redeemer_user_whitelist)
WHERE redeemer_user_whitelist=idcypher(${USER})
ORDER BY voucher_campaign_id DESC ;

-- ******************************************************************************************************************
-- ******************************************************************************************************************
-- ******************************************************************************************************************

--------------------------------------------
-- Comprobació 1
SELECT
	reason,	"comment",	count(*) AS usuaris,	sum(td.quantity) AS bons,
	avcq."name" AS quota, avcq.quantity AS "Q-limit"
FROM api_voucher_campaign_custom_assignment_delta td ,
	 api_voucher_campaign_quota avcq
WHERE
	avcq.id = td.quota_id
GROUP BY GROUPING SETS ((reason,	avcq."name", "comment",	avcq.quantity),	())
ORDER BY
	reason,	COMMENT;

--------------------------------------------
-- Comprobació 2
-- ================================
-- DETALL: De bons GIVEN i BOUGHT
SELECT
	user_id AS idcyclos,
	iddecypher(td.user_id) AS id,
	SUM(td.quantity) AS given, string_agg(td.reason || '(' || td.quantity || ')', ' + ')
FROM
	api_voucher_campaign_custom_assignment_delta td
WHERE
	campaign_id = 7
GROUP BY
	user_id,
	iddecypher(td.user_id)
ORDER BY
	given DESC;


-- Resum de bons donats/comprats per usuari
SELECT * FROM mv_bonusers_prod tb 
WHERE username ~* 'VANEXPA'
--username='anamariafresneda' LIMIT 50;

-- Resum de bons donats/comprats per usuari AGRUPAT per GRUP
SELECT given, bought, count(*) --, string_agg(''||tbp.id, ', ')
  FROM mv_bonusers_prod tbp
 GROUP BY given, bought
 ORDER BY given, bought;

  WITH tmp_delta22 AS 
(SELECT iddecypher(user_id) AS id, sum(quantity) AS given
   FROM api_voucher_campaign_custom_assignment_delta td
  WHERE campaign_id = 2
	AND td.reason<>'BW2022 Rebuy2020'
	GROUP BY user_id),
 tmp_delta21 AS 
(SELECT iddecypher(user_id) AS id, COALESCE(sum(quantity),0) AS given
   FROM api_voucher_campaign_custom_assignment_delta td
  WHERE campaign_id = 2
	AND td.reason='BW2022 Rebuy2020'
	GROUP BY user_id)
SELECT
	mbp.given AS given, COALESCE(d21.given,0) AS given21, COALESCE(d22.given,0) AS given22, 
	mbp.bought AS bought, count(*)
FROM
	mv_bonusers_prod mbp
	LEFT OUTER JOIN  tmp_delta22 d22 ON (d22.id=mbp.id)
	LEFT OUTER JOIN  tmp_delta21 d21 ON (d21.id=mbp.id)
GROUP BY
	mbp.given, d22.given, d21.given, mbp.bought
ORDER BY
	given, given22, bought;



SELECT user_id, sum(quantity) AS given, sum(spent) AS bought, count(user_id)
			  FROM api_voucher_campaign_custom_assignment ca 
	 		 WHERE campaign_id = 0
			 GROUP BY user_id
			 HAVING sum(spent)>0
			 ORDER BY user_id
	
-- Consulta comparada entre BONUSERS i VCCA (voucher_campaign_custom_assignment)
SELECT status, grup, 
	   count(DISTINCT dni) AS n_usu, 
	   sum(CASE WHEN given > 0 THEN 1 ELSE 0 END) AS n_given,
	   sum(CASE WHEN bought > 0 THEN 1 ELSE 0 END) AS n_buy, 
       sum(given) AS given, sum(bought) AS bought,
       sum(given_vcca) AS given_vcca, sum(bought_vcca) AS bought_vcca
 FROM mv_bonusers_prod n
GROUP BY GROUPING SETS ((status, grup),(status),())
ORDER BY status, grup NULLS LAST;

-- =============== WHITELIST (1A) ============================================ WHITELIST ============
-- =============== WHITELIST (1A) ============================================ WHITELIST ============
-- =============== WHITELIST (1A) ============================================ WHITELIST ============
-- =============== WHITELIST (1A): Dos bons inicials (viuen VLD) ===============================
INSERT xx INTO	api_voucher_campaign_custom_assignment_delta
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
INSERT xx INTO	api_voucher_campaign_custom_assignment_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 1-2', 2, 'Bons 1-2: Per treballar a Viladecans', 
           now(), idcypher(u.id), 2, 1
	FROM
		cyclos_users u
	WHERE
		u.id IN (SELECT id FROM tmp_white_workers)
		AND u.status = 'ACTIVE');

-- =============== WHITELIST (1C): Dos bons inicials (cheaters VLD) =============================
INSERT xx INTO	api_voucher_campaign_custom_assignment_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 1-2', 2, 'Bons 1-2: Per domicili(*) a Viladecans',
           now(), idcypher(u.id), 2, 1
	FROM
		cyclos_users u
	WHERE
		u.network_id = 2
		AND u.id IN (SELECT id FROM tmp_white_cheaters));

-- =============== WHITELIST (2) ============================================ WHITELIST ============
-- =============== WHITELIST (2) ============================================ WHITELIST ============
-- =============== WHITELIST (2) ============================================ WHITELIST ============
-- =============== WHITELIST (2): Recompra bons 2020 =============================
-- Campaign_id = 2 (Bons Vilawat 2022)
INSERT xx INTO	api_voucher_campaign_custom_assignment_delta
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

-- =============== WHITELIST (3) ============================================ WHITELIST ============
-- =============== WHITELIST (3) ============================================ WHITELIST ============
-- =============== WHITELIST (3) ============================================ WHITELIST ============
-- =============== WHITELIST (3): Tercer bo (habitants VLD) =============================
--DELETE FROM  tmp_delta WHERE reason='BW2022 3';
INSERT xx INTO	api_voucher_campaign_custom_assignment_delta
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

-- Retracció de 3r bo als que encara no l'han gastat (juliol→setembre)
INSERT xx INTO	api_voucher_campaign_custom_assignment_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 3', -1, 'Bo 3: Retracció de 3r bo fins setembre', 
           now(), idcypher(u.id), 2, 2
	FROM
		cyclos_users u
	WHERE
		u.network_id = 2
		AND u.id IN (
			-- Tenen un 3r bo per gastar
			SELECT iddecypher(user_id)
			  FROM api_voucher_campaign_custom_assignment 
			 WHERE campaign_id =2
			   AND quota_id = 2
			   AND quantity > spent
			)
        AND u.status = 'ACTIVE'
	);

-- JULIOL == Reinserció de 3r bo a usuaris puntuals VIPs
INSERT xx INTO	api_voucher_campaign_custom_assignment_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id)
   (SELECT 'BW2022 3', 1, 'Bo 3: Per domicili/feina a Viladecans (VIPs amb saldo >50€)', 
           now(), idcypher(u.id), 2, 2
	FROM
		cyclos_users u
	WHERE
		u.network_id = 2
		AND u.id IN (5263)
        AND u.status = 'ACTIVE'
	);
-- Comprobació inserció VIP
--SELECT * FROM api_voucher_campaign_custom_assignment_delta
--WHERE user_id IN (idcypher(1904), idcypher(735))

-- ----------------------------
-- DESEMBRE == Insercio 2 Bons Restauració per tothom ACTIU de Viladecans
-- ----------------------------
SELECT * FROM api_voucher_campaign avc WHERE id=3;
SELECT * FROM api_voucher_campaign_quota avcq WHERE id=4;

INSERT INTO	api_voucher_campaign_custom_assignment_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
   (SELECT 'BW2022 Rest-4-All', 2, '2 Bons Restauració (desembre)', 
           now(), idcypher(u.uid), 3, 4, FALSE 
	FROM
		tmp_rest4all u
	);



-- SETEMBRE == Reinserció de 4t bo als que encara ho mereixen i no l'han comprat al juliol
--             Caldrà ampliar cron[5]→cron_bons12() perquè afegeixi el 3r bo també
-- ASSIGNACIÓ Bons Restauració (compra)
INSERT INTO	api_voucher_campaign_custom_assignment_delta
   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
   (SELECT 'BW2022 4', 1, 'Bo 4: Inserció 4t bo (desembre)', 
           now(), idcypher(u.id), 2, 5, FALSE 
	FROM
		cyclos_users u
	WHERE
		u.network_id = 2
		AND u.status ='ACTIVE'
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
			-- Ja se'ls ha assignat el 4t bo
			SELECT iddecypher(user_id)
			  FROM api_voucher_campaign_custom_assignment 
			 WHERE campaign_id =2
			   AND quota_id = 5     -- Quota 4r BO
			   AND quantity > 0
			   )
	);


INSERT INTO api_voucher_campaign_quota (id, GENERAL, name, quantity, campaign_id)
VALUES (5, FALSE, 'BW22 Quart bo', 5000, 2);

SELECT * FROM api_voucher_campaign_quota avcq ORDER BY id 

-- >>>>>>>>>>>>>>>>>>>>
-- cron[5] --- CALL cron_bons12() --- Comanda diària d'assignació de 2 bons als nous usuaris
-- >>>>>>>>>>>>>>>>>>>>
SELECT
	mcu."name", avccad 
FROM
	api_voucher_campaign_custom_assignment_delta avccad
	LEFT OUTER JOIN mv_cyclos_users mcu ON (avccad.user_id=mcu.idcyclos)
WHERE "timestamp" >= now()-'1 day'::interval
ORDER BY
	"timestamp" DESC


-- =======================================================================================
-- =======================================================================================

SELECT * FROM api_composite_transaction act 
WHERE ticket_status = 'PROCESSED'
ORDER BY id  DESC LIMIT 100;

SELECT ticket_type, count(*)
  FROM api_composite_transaction act 
 WHERE ticket_status =	 'PROCESSED'
 GROUP BY ticket_type;

SELECT ticket_status, count(*)
  FROM api_composite_transaction act 
 GROUP BY ticket_status;



SELECT * FROM mv_payments LIMIT 50;

-- Llistat de pagaments SOSPITOSOS d'empreses a particulars
SELECT process_date, 
  	   payer_name||' ('||iddecypher(payer_id)||')' AS payer_name, 
	   payee_name||' ('||iddecypher(payee_id)||')' AS payee_name,
	   t_amount, t_due, v_due, v_redeem, p_amount,
	   payer_grup, payee_grup
  FROM mv_payments 
  WHERE payer_grup <> 'Particulars'
    AND payee_grup = 'Particulars'
 ORDER BY payer_name ;

SELECT -- 0 AS ac_id, 'Pagament amb bons' AS t_type, 
       process_date, iddecypher(694825523465018063), * 
  FROM mv_payments 
  WHERE payer_id = 694825523465018063
     OR payee_id = 694825523465018063
 ORDER BY process_date ;


WITH sums AS (
	SELECT payer_grup AS orig, payee_grup AS dest, count(*) AS num, 
		   sum(t_amount) AS t_amount, sum(t_due) AS t_due,
		   sum(v_due) AS v_due, sum(v_redeem) AS v_redeem,
		   sum(p_amount) AS p_amount
	  FROM mv_payments 
	 GROUP BY payer_grup, payee_grup
	 ORDER BY payer_grup, payee_grup
)
SELECT  orig, dest, num, 
		t_amount, round(100*t_amount / sum(t_amount) OVER (),1) AS "T%",
		t_due, v_due, v_redeem, 
		p_amount, round(100*p_amount / sum(p_amount) OVER (),1) AS "P%"
  FROM sums
 ORDER BY "T%" desc;
	

SELECT * FROM mv_cyclos_users mcu WHERE name~*'catarineu'

@set f_tx = VW-000055071
@set f_tx = 20024
SELECT *
  FROM api_composite_transaction act
 WHERE id = 20024 --${f_tx}
   
SELECT *
  FROM mv_payments
 WHERE id = ${f_tx}

 
 SELECT * FROM api_composite_transaction_payments
 ORDER BY "timestamp" DESC LIMIT 10; 


SELECT
	timestamp AS date,
	mcu1.id AS payer, 
	mcu2.id AS payee, 'Voucher ' || lower(av.status) AS t_type,
	av.amount AS amount, 0 AS w_saldo, av.amount AS w_bons, NULL AS bons,
	mcu1.grup AS payee_grup, mcu2.grup AS payee_grup, 'camp='||av.campaign_id||',bonus='||LEFT(av.code,8) AS info
FROM 
	api_voucher_event_log vel
	LEFT OUTER JOIN mv_cyclos_users mcu1 ON (vel.from_user_id=mcu1.idcyclos)
	LEFT OUTER JOIN mv_cyclos_users mcu2 ON (vel.to_user_id  =mcu2.idcyclos)
	LEFT OUTER JOIN api_voucher av ON (av.id=vel.voucher_id)
WHERE
	(to_user_id =idcypher(${f_user})	OR from_user_id =idcypher(${f_user}))
	AND	timestamp > ${f_date}
ORDER BY timestamp;

	
SELECT
	vel, av
FROM 
	api_voucher_event_log vel
	LEFT OUTER JOIN mv_cyclos_users mcu1 ON (vel.from_user_id=mcu1.idcyclos)
	LEFT OUTER JOIN mv_cyclos_users mcu2 ON (vel.to_user_id  =mcu2.idcyclos)
	LEFT OUTER JOIN api_voucher av ON (av.id=vel.voucher_id)
WHERE
	(to_user_id =idcypher(${f_user})	OR from_user_id =idcypher(${f_user}))
	AND timestamp > ${f_date}
ORDER BY timestamp


SELECT
	event_type,
	count(*)
FROM
	api_voucher_event_log vel
WHERE
	timestamp >= '2022-01-01'
GROUP BY
	event_type

-- ==========================================================================================
-- Petició Carles Ferreiro: Permetre 3r bo a aquells que hagin recarregat recentment        → FET: Maria Buendia Muñoz (5263)
-- ==========================================================================================
@set f_date = '2022-01-01'
WITH
-- Aquells que ARA tenen un saldo > 50₩
   ambsaldo AS (
		SELECT a.user_id
		FROM   cyclos_accounts a
			   LEFT OUTER JOIN cyclos_account_balances ab ON (ab.account_id=a.id)
		WHERE  ab.balance > 50
-- Aquells que han fet un cash-in el darrer mes
), ambcashin AS (
	SELECT a.user_id AS user_id
	  FROM cyclos_accounts a 
		   LEFT OUTER JOIN cyclos_transfers t ON (t.to_id=a.id)
	 WHERE type_id = 10 -- Dipòsit (cash-in)
 	 GROUP BY a.user_id
	HAVING max(date) > (now()-'1 month'::INTERVAL)
) SELECT  -- FUSIÓ 2: CONSULTA moviments CYCLOS
		a.user_id, t."date", mcu1.name||' ('||mcu1.id||')' AS payer, mcu2."name"||' ('||mcu2.id||')' AS payee, tt.name AS t_type, 
		CASE WHEN mcu2.id=a.user_id  THEN t.amount ELSE -t.amount END AS amount, 
		CASE WHEN mcu2.id=a.user_id  THEN t.amount ELSE -t.amount END AS w_saldo, 0 AS w_bons, NULL AS bons, 
		mcu1.grup AS payer_group, mcu2.grup AS payee_group, 
		t.subclass ||',  tx='|| t.transaction_number ||',  tid='|| t.id AS details
	FROM
		cyclos_accounts a 
		LEFT OUTER JOIN cyclos_transfers t ON (t.from_id=a.id OR t.to_id=a.id)
		LEFT OUTER JOIN cyclos_transfer_types tt ON (t.type_id=tt.id)
		LEFT OUTER JOIN cyclos_accounts a1 ON (a1.id=t.from_id)
		LEFT OUTER JOIN cyclos_accounts a2 ON (a2.id=t.to_id)
		LEFT OUTER JOIN mv_cyclos_users mcu1 ON (mcu1.id=a1.user_id)
		LEFT OUTER JOIN mv_cyclos_users mcu2 ON (mcu2.id=a2.user_id)
  WHERE a.user_id IN (SELECT user_id FROM ambsaldo)  AND
		a.user_id IN (SELECT user_id FROM ambcashin) AND
		a.user_id <> 654                             AND -- NO m'ensenyis Xarxa
		date >  (now()-'1 month'::INTERVAL)
UNION
	SELECT -- FUSIÓ 4: CONSULTA saldo actual en ₩ de l'usuari
		a.user_id, now() AS date, NULL AS payer, mcu."name"||' ('||mcu.id||')' AS payee, 
		'SALDO ACTUAL' as t_type, 0 AS amount, ab.balance AS w_saldo, 0 AS w_bons, NULL AS bons,
		NULL AS payer_grup, mcu.grup AS payee_grup, NULL AS info
	FROM
		cyclos_accounts a
		LEFT OUTER JOIN cyclos_account_balances ab ON (ab.account_id=a.id)
		LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.id=a.user_id)
  WHERE a.user_id IN (SELECT user_id FROM ambsaldo)  AND
		a.user_id IN (SELECT user_id FROM ambcashin) AND
		a.user_id <> 654                                 -- NO m'ensenyis Xarxa
ORDER BY user_id, date, t_type;

