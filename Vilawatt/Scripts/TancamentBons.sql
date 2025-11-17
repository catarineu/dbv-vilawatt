-- Tria de campanyes
SELECT id, voucher_type, begin_date, "name" FROM voucher_campaign vc ORDER BY id desc;

-- Extracció bons
SELECT
 	'\lo_export ' || data || ' ''/Users/jaume/bons24/' || 
 	ct.id || '--' || string_agg(left(v.code,8),'-') ||
 	'.' || split_part(contenttype,'/',2) || ''''
 FROM
     voucher v
     JOIN composite_transaction_vouchers ctv   ON	ctv.voucher_id = v.id
     JOIN composite_transaction ct             ON	ct.id = ctv.composite_transaction_id
     JOIN composite_transaction_attachment cta ON	cta.transaction_id = ct.id
     JOIN stored_file sf                       ON	cta.file_id = sf.id
 WHERE
 	cta.type = 'TICKET' AND v.status = 'REDEEMED'
   AND v.campaign_id IN (7,8)
 GROUP BY 
 	data, ct.id,contenttype;
 	
