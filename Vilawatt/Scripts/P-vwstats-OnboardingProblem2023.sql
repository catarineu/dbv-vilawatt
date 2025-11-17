WITH affected AS (
	SELECT mcu.dni, mcu.name, cusl.status, cusl.start_date, end_date
	  FROM mv_cyclos_users mcu
	       LEFT OUTER JOIN cyclos_user_status_logs cusl ON (cusl.user_id=mcu.id)
	 WHERE cusl.start_date > '2023-01-01'
	   AND (cusl.status='DISABLED' OR cusl.status='PENDING')
	   AND (cusl.end_date IS NULL  OR cusl.end_date >= '2023-12-28')
	 ORDER BY mcu.dni 
), unaffected AS (
	SELECT DISTINCT mcu.dni, mcu.name, cusl.status, cusl.start_date, end_date
	  FROM mv_cyclos_users mcu
	       INNER JOIN cyclos_user_status_logs cusl ON (cusl.user_id=mcu.id)
     WHERE cusl.status='ACTIVE' 
       AND cusl.start_date BETWEEN '2023-09-01' AND '2023-12-28' 
), llista AS (
	SELECT mcu.id AS user_id, dni, name, cusl.status, cusl.start_date, end_date, email
	  FROM mv_cyclos_users mcu
	       LEFT OUTER JOIN cyclos_user_status_logs cusl ON (cusl.user_id=mcu.id)
	 WHERE dni     IN (SELECT dni FROM   affected WHERE dni IS NOT NULL)
       AND dni NOT IN (SELECT dni FROM unaffected WHERE dni IS NOT NULL)
), results AS (
	SELECT user_id, dni, name, email,
			string_agg(status || '  ' || COALESCE(start_date::date::text,'...') || '-' || COALESCE (end_date::date::text,'...'), ', ' ORDER BY start_date DESC) AS estats
	  FROM llista
     GROUP BY user_id, dni, name, email
	 ORDER BY dni, user_id DESC
) SELECT DISTINCT * FROM results;


	SELECT DISTINCT mcu.dni, mcu.name, mcu.grup, cusl.status, cusl.start_date, end_date
	  FROM mv_cyclos_users mcu
	       INNER JOIN cyclos_user_status_logs cusl ON (cusl.user_id=mcu.id)
     WHERE cusl.status='ACTIVE' 
       AND cusl.start_date BETWEEN '2023-09-01' AND '2024-12-28' 
