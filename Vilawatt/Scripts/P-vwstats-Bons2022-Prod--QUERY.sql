-- Detecció d'anomalies
REFRESH MATERIALIZED VIEW mv_cyclos_users;
REFRESH MATERIALIZED VIEW mv_bonusers_prod;
REFRESH MATERIALIZED VIEW mv_payments;

WITH a AS (
SELECT 
	t.id, t."date"::timestamp(0), 
	LEFT(mcu2.name,20)||'...('||mcu2.id||')' AS payee, tt.name AS t_type, 
	t.amount AS amount,
	LEFT(mcu2.grup,20) AS payee_group, 
	t.subclass ||',  tx='|| t.transaction_number ||',  tid='|| t.id AS details
FROM
	cyclos_accounts a 
	LEFT OUTER JOIN cyclos_transfers t ON (t.to_id=a.id)
	LEFT OUTER JOIN cyclos_transfer_types tt ON (t.type_id=tt.id)
	LEFT OUTER JOIN cyclos_accounts a2 ON (a2.id=t.to_id)
	LEFT OUTER JOIN mv_cyclos_users mcu2 ON (mcu2.id=a2.user_id)
WHERE
	date > '2024-12-01'
	AND tt."name" ='Dipòsit (cash-in)'
ORDER BY amount DESC) 
SELECT sum(amount) FROM a;

------------------------------------------------- 
------------------------------------------------- 
-- Consulta d'establiments de restauració

-- CAMPANYES:  7=Consum,  8=Verds
-- QUOTES   : 11=Consum, 12=Verds

SELECT ROW_NUMBER() OVER (ORDER BY cu.name, voucher_campaign_id) as row_num, voucher_campaign_id AS campaign, cu.id, cu.name
  FROM api_voucher_campaign_redeemer_user_whitelist avcruw
 	   LEFT OUTER JOIN mv_cyclos_users cu ON (avcruw.redeemer_user_whitelist=cu.idcyclos)
WHERE voucher_campaign_id IN (8)
ORDER BY name, voucher_campaign_id ;

-- Inserció massiva
INSERT INTO api_voucher_campaign_redeemer_user_whitelist 
(SELECT 8, idcyclos 
   FROM mv_cyclos_users 
  WHERE username IN ('110116','2980fbp','31011995','441937','52916014y','60208808','a.khian','a.niusalu','adriana','altayorodriguez','anubis','aranmireia','assessoriajj','asun60','avira','b.esports','baca.carn','bar.petit','biancomobiliari','bongust','braulio','caldelaia','calsei','candido','caprichos','carn.dia','carnivors','casama','casatorrens','cauela','celifruits','chebrolet','chezsabine','clickame','comigraf','damitas','danielto1969','desireeluna','drogueria1','dulcesinma','electrocalbet1','electrocalbet2','lsnourals','events19','farma.riera','farma.roca','farma.sala','farmacia.niubo','faraciabergamarti','farmaciamgarrido','fisioimes','floristeriajazmin','fruitsmarcel','arciayolivares','gessami','gestoriapena','glamourbyvero','handcake','helendoron','hrboristeriacamamilla','imma.m.z','inizio','inortia','j.necen','j.seven','jesusop','joya.guerrero','ladorada','ladrimancha','lamolino','leben.cafe','lluisala','loli.pex','loliluque','lulamuk','m.ipper','maitancat','marc00','maricarmensuro','marijos','martapt','mingogastronomia','miquelcaimary','mireiavaro','miyointerior','modajoublin','modasport','mplata','mvaquerizo','mynube','neusfer','novavila','noveluz','nuri1006','okfruites','optica2007','opticaronda','paniagua','peribet','pescados','querol','raquelfloristeries','riutori','salut.niu','santacreu','secretsvila','sergiohogando','solopeques','sortida','susanaruiz','taquetes','tropicalmanaos','v.ferreteria','vilatinta')
) ON CONFLICT DO NOTHING;

DELETE FROM public.api_voucher_campaign_redeemer_user_whitelist
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM public.api_voucher_campaign_redeemer_user_whitelist
    GROUP BY voucher_campaign_id, redeemer_user_whitelist
);

CREATE TABLE tmp_whitebackup AS (SELECT * FROM api_voucher_campaign_redeemer_user_whitelist);

-- Inserció puntual  
IINSERT INTO api_voucher_campaign_redeemer_user_whitelist VALUES (7, idcypher(2109));

------------------------------------------------- 
------------------------------------------------- 

-- Identificació usuari amb problemes
SELECT id, name, username, email
  FROM cyclos_users cu  
 WHERE name ~* 'LOPVI';

SELECT owner_id AS id, mcu."name", cucf."name" AS nom, ucfv1.field_id , string_value AS valor
  FROM cyclos_user_custom_field_values ucfv1
	   LEFT OUTER JOIN cyclos_user_custom_fields cucf ON (cucf.id=ucfv1.field_id)
	   LEFT OUTER JOIN mv_cyclos_users mcu ON (mcu.id=ucfv1.owner_id)
 WHERE upper(ucfv1.string_value) IN (
'LOPVILALOP SL',
'LLONCH PORTA PROJECTES, SL',
'AMPA TEIDE',
'FRAPE TAPAS SL',
'UNION DEPORTIVA VILADECANS',
'VILARECONS, S.L:',
'XARCUTERIA',
'S-0800481-D',
'JOQUER TAPICERIAS, S.A.',
'INVERSIONES SUPRADENT 0512 S.L',
'COMUNITAT .PROP. C DOCTOR AUGUET, 49',
'DISEÑOS INDUSTRIALES LAMI,  SL',
'WARIACH Y SANDHU SCP',
'CDAD PROP DE LA CL DOCTOR REIG, 61',
'BIKEXTREM BAIX,  S.L.',
'LANGUAGE CONCEPT COMMUNICATION, S.L',
'REGISTRE D ARTS GRAFIQUES SA',
'QUATTRO BAR VILADECANS SL',
'GAC PELUQUERIAS S.L.')

SELECT id, name, username, email, naix, grup
  FROM mv_cyclos_users mcu 
 WHERE
       upper(name) IN (
'DECORPLAC INTERIORISMO Y DECORACION SL',
'CDAD DE PROPIETARIOS ALZINA 5',
'COMUNITAT DE PROPIETARIS C DR REIG',
'SENYORET SCP',
'INCUBOUT SL',
'MOBLES ARAN',
'ESCOLA GERMANS AMAT I TARGA',
'ESCOLA CAN PALMER',
'ESCOLA MONTSERRATINA',
'ESCOLA MARTA MATA',
'GABINETE AGUAR GARCIA SLP',
'CASTILLA HC VILADECANS SL',
'REDINDOOR S.L.',
'TOIS DECOR S.C.P',
'CLUB ESPORTIU TOTS A CAVALL'
)  ORDER BY name;

@set f_user = 24
@set f_date = '2022-01-01'
@set f_glen = 14

-- Quants bons té assignats/comprats 
SELECT *  FROM mv_bonusers_prod n WHERE id=${f_user};

-- Per què se li han assignat bons
SELECT timestamp::date AS DATA, COMMENT AS motiu, quantity AS num_bons, reason AS codi
FROM api_voucher_campaign_custom_assignment_delta avccad WHERE user_id=idcypher(${f_user})
ORDER BY timestamp;

SELECT motiu, num_bons, data FROM vw_b2_bonsAssignats(${f_user});

-- Control whitelist i adreça
	SELECT owner_id AS id, cucf."name" AS nom, string_value AS valor
	  FROM cyclos_user_custom_field_values ucfv1
		   LEFT OUTER JOIN cyclos_user_custom_fields cucf ON (cucf.id=ucfv1.field_id) 
	 WHERE ucfv1.owner_id = ${f_user}
	   AND ucfv1.field_id IN (77, 78, 79, 80)
UNION
	SELECT ${f_user} AS id, 'O- Whitelist (treballa a VLD)' AS nom, 
		   CASE WHEN ${f_user} IN (SELECT id FROM  tmp_white_workers tww) THEN 'TRUE' ELSE 'FALSE' END
UNION
	SELECT ${f_user} AS id, 'O- Accés a bons 1-2 per ERROR' AS nom, 
		   CASE WHEN ${f_user} IN (SELECT id FROM  tmp_white_cheaters twc) THEN 'TRUE' ELSE 'FALSE' END
ORDER BY nom;
	  
-- === DETALL de moviments bons -- Per enviar a usuaris ======================================
SELECT -- FUSIÓ 1: CONSULTA moviments PAGAMENTS_COMPOSTOS
	   min(process_date)::timestamp(0) AS date,  
	   ' Usuari ('||iddecypher(payer_id)||')' AS payer, 
	   LEFT(payee_name,20)||'...('||iddecypher(payee_id)||')' AS payee, 
	   '*** Pagament APP ***'::text AS t_type, 
	   CASE WHEN payee_id=idcypher(${f_user}) THEN t_amount ELSE -t_amount END AS amount, 
       t_due AS w_saldo, 
       CASE WHEN payee_id=idcypher(${f_user}) THEN sum(v_redeem) ELSE -sum(v_redeem) END  AS w_bons,
       string_agg(''||v_redeem,';') AS bons, LEFT(payer_grup,20) AS payer_grup , LEFT(payee_grup,20) AS payee_grup,
       'txs=' AS info
  FROM mv_payments 
 WHERE (payer_id = idcypher(${f_user}) OR payee_id = idcypher(${f_user}))
   AND process_date > ${f_date}
 GROUP BY id, payer_name, payee_name, payer_id, payee_id, t_amount, payer_grup , payee_grup, t_due
 ORDER BY date, t_type;
