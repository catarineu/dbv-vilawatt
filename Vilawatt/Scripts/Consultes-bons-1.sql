SELECT * FROM  voucher_campaign_redeemer_user_whitelist; 

-- Alta de comerç com a acceptador de bons
INSERT INTO public.voucher_campaign_redeemer_user_whitelist 
	(voucher_campaign_id, redeemer_user_whitelist) 
VALUES(10, 5306511541892405794);
--SELECT DISTINCT redeemer_user_whitelist FROM voucher_campaign_redeemer_user_whitelist vcruw;

-- Cerca usuaris
SELECT id, idcypher(id) AS id2, name, email, status, * FROM cyclos_users cu WHERE "name" ~ 'Torrico';

-- Consulta assignacions
SELECT * 
  FROM api_voucher_campaign_custom_assignment_delta avccad 
 WHERE campaign_id IN (9,10)
   AND user_id = -5646242751872640475;

-- Bons de test per Ubiquat
IINSERT INTO public.voucher_campaign_custom_assignment_delta 
("comment", quantity, reason, "timestamp", user_id, campaign_id, quota_id, hidden) 
VALUES('Bo consum #1-2: Test UBIQUAT', 2, 'BC2025#1-2', now(), 1271286275768441593, 9, 13, false);
