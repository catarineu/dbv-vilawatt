-- ============================================================
-- Preparació de PG_CRON
-- ============================================================
-- CREATE EXTENSION pg_cron;
-- GRANT USAGE ON SCHEMA cron TO vwstats;
-- SELECT name, setting, short_desc FROM pg_settings WHERE name LIKE 'cron.%' ORDER BY name; -- Settings

-- ============================================================
-- ┌───────────── min (0 - 59)
-- │ ┌────────────── hour (0 - 23)
-- │ │ ┌─────────────── day of month (1 - 31)
-- │ │ │ ┌──────────────── month (1 - 12)
-- │ │ │ │ ┌───────────────── day of week (0 - 6) (0 to 6 are Sunday to
-- │ │ │ │ │                  Saturday, or use names; 7 is also Sunday)
-- * * * * *
-- https://crontab.guru/

-- ============================================================
-- Programació de tasques
-- ============================================================
-- SELECT cron.schedule('<Job name>', '<Schedule>', '<Task>')   -- Create
-- SELECT cron.unschedule(<ID of the scheduled task>)           -- Delete

-- == JOBS =================================================================================
-- (Cada hora:01) Assignació automàtica de bons 1+2 als qui ho mereixen i no els tenen  
--SELECT Xcron.schedule('Vilawatt MV refresh', '0 * * * *', 'REFRESH MATERIALIZED VIEW mv_cyclos_users; REFRESH MATERIALIZED VIEW mv_bonusers_prod; REFRESH MATERIALIZED VIEW mv_payments;');
--SELECT Xcron.schedule('Vilawatt Bons 2022 1+2', '5 * * * *', 'CALL cron_bons12()');

-- (Cada dia) Purgat logs antics  
--SELECT Xcron.schedule('PG_CRON: cron.job_run_details cleanup', '0 0 * * *', $$DELETE FROM cron.job_run_details WHERE end_time < now() - interval '15 days'$$);

-- username & database!!
--UPDATE Xcron.job SET DATABASE='vwstats', username='vwstats' WHERE jobid=...;

-- == REVIEW ===============================================================================
-- View current jobs
SELECT jobid AS id, schedule AS w, jobname, DATABASE, username, active AS "I/O", command  FROM cron.job ORDER by DATABASE, username, schedule, jobname;                                      -- View
SELECT * FROM cron.job ORDER by jobname;                                      -- View

-- View jobs results
SELECT * FROM cron.job_run_details ORDER by runid DESC LIMIT 150;


/*
ERROR: could not serialize access due to concurrent update
CONTEXT: SQL statement "insert into public.voucher_campaign_custom_assignment(campaign_id, quota_id, user_id, quantity, spent, "timestamp")
( select d.campaign_id, d.quota_id, d.user_id, sum(d.quantity), 0 as spent, now() as "timestamp"
from public.voucher_campaign_custom_assignment_delta d
inner join (select distinct campaign_id, quota_id, user_id from newtable) nt
on d.campaign_id = nt.campaign_id and d.quota_id = nt.quota_id and d.user_id = nt.user_id
group by d.campaign_id, d.quota_id, d.user_id
)
on conflict (campaign_id, quota_id, user_id )
do update set quantity = EXCLUDED.quantity, "timestamp" = EXCLUDED."timestamp""
PL/pgSQL function public.fn_trg_voucher_campaign_custom_assignment_update_snapshots() line 14 at SQL statement
remote SQL command: INSERT INTO public.voucher_campaign_custom_assignment_delta(comment, quantity, reason, "timestamp", user_id, campaign_id, quota_id, hidden) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
SQL statement "WITH myrows AS (
		INSERT INTO	api_voucher_campaign_custom_assignment_delta
		   (reason, quantity, "comment", "timestamp", user_id, campaign_id, quota_id, hidden)
		   (WITH prev AS (SELECT iddecypher(user_id) AS uid, sum(quantity) AS quantity
						    FROM api_voucher_campaign_custom_assignment 
					  	   WHERE campaign_id = 5
						     AND quota_id in (9)
						     AND quantity > 0
						   GROUP BY user_id)
			SELECT 'BR2023#1-2', 
			       GREATEST(0,2-COALESCE(prev.quantity,0)::int) AS quant, -- Afegeixo dif. fins 1 bons, mai negatiu!
			       'Bo restauració #1-2: Per domicili/treball a Viladecans (auto)' AS descr, 
		           now(), idcypher(u.id), 5, 9, FALSE
			FROM
				cyclos_users u
				LEFT OUTER JOIN prev ON (prev.uid=u.id)
				LEFT OUTER JOIN (SELECT DISTINCT uid, ACTION FROM tmp_purgat_2023) tmp ON (tmp.uid=u.id)
			WHERE
				(tmp.action='OK' OR tmp.ACTION IS NULL) -- particular.OK + autonoms/empreses
	        AND u.status = 'ACTIVE'
			AND u.network_id = 2
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
			AND u.id NOT IN (SELECT uid FROM prev WHERE quantity>=2)
		) RETURNING 1
	) SELECT count(*)            FROM myrows"
PL/pgSQL function cron_bons12() line 44 at SQL statement