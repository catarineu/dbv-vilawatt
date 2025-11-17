--CREATE OR REPLACE TEMP VIEW ubiquat_report_ede_accounts AS

-- TC_UBIQUAT: First export from DB.AGANEA, then import into DB.VWSTATS
WITH my_login AS (
	SELECT user_id, max(date_time) AS last_login
 	  FROM login_history_logs lhl2 
	 GROUP BY user_id
)
SELECT --r.id, 
		r.user_id, u.name,
		coalesce(ucfv1.string_value, ucfv2.string_value) as doc_id,
		lhl.last_login, r.creation_date, -- r.last_modify_date, rt.internal_name,
		cfv1.integer_value as cyclos_cc_id,
		cfv2.string_value as ede_cc_id,
		cfv3pv.internal_name as ede_cc_type,
		cfv4.decimal_value as ede_cc_balance
  FROM records r
       JOIN record_types rt on r.type_id = rt.id  and rt.internal_name = 'edeAccountUserRecord'
       JOIN networks n on n.id = rt.network_id and n.internal_name = 'vwlive'
       JOIN record_custom_fields cf1 on cf1.record_type_id = rt.id and cf1.internal_name = 'cyclosAccountId'
       JOIN record_custom_fields cf2 on cf2.record_type_id = rt.id and cf2.internal_name = 'edeRemoteAccountNumber'    
       JOIN record_custom_fields cf3 on cf3.record_type_id = rt.id and cf3.internal_name = 'edeAccountType'
       JOIN record_custom_fields cf4 on cf4.record_type_id = rt.id and cf4.internal_name = 'balance'
       LEFT JOIN record_custom_field_values cfv1 on cfv1.field_id = cf1.id and cfv1.owner_id = r.id
       LEFT JOIN record_custom_field_values cfv2 on cfv2.field_id = cf2.id and cfv2.owner_id = r.id
       LEFT JOIN record_custom_field_values cfv3 on cfv3.field_id = cf3.id and cfv3.owner_id = r.id
       JOIN record_enum_values enums on enums.owner_id = cfv3.id
       JOIN record_custom_field_possible_values cfv3pv on enums.possible_value_id = cfv3pv.id
       LEFT JOIN record_custom_field_values cfv4 on cfv4.field_id = cf4.id and cfv4.owner_id = r.id
       LEFT JOIN users u on u.id = r.user_id
       JOIN user_custom_fields ucf1 on ucf1.internal_name = 'nif' and ucf1.network_id = n.id
       JOIN user_custom_fields ucf2 on ucf2.internal_name = 'idDocumentNumber' and ucf1.network_id = n.id
       LEFT JOIN user_custom_field_values ucfv1 on ucfv1.field_id = ucf1.id and ucfv1.owner_id = u.id
       LEFT JOIN user_custom_field_values ucfv2 on ucfv2.field_id = ucf2.id and ucfv2.owner_id = u.id
       LEFT JOIN my_login lhl ON lhl.user_id = u.id
--WHERE u.name ~* 'CATARI'
   ORDER BY last_login DESC, (cfv4.decimal_value>0) DESC NULLS LAST, creation_date desc;
 
-- ede_account_id i ede_account_type