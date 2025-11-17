-- API.voucher_campaign_custom_assignment
-----------------------------------------
DROP FOREIGN TABLE api_voucher_campaign_custom_assignment;
CREATE FOREIGN TABLE api_voucher_campaign_custom_assignment (
	id bigserial NOT NULL,
	"comment" varchar(255) NULL,
	quantity int4 NOT NULL,
	spent int4 NULL,
	"timestamp" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	user_id int8 NOT NULL,
	campaign_id int8 NOT NULL,
	quota_id int8 NOT NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'voucher_campaign_custom_assignment');
-- TEST
SELECT * FROM api_voucher_campaign_custom_assignment LIMIT 1;


-- API.voucher_campaign_custom_assignment_delta
----------------------------------------- 
DROP FOREIGN TABLE api_voucher_campaign_custom_assignment_delta;
CREATE FOREIGN TABLE api_voucher_campaign_custom_assignment_delta (
--	id bigserial NOT NULL,
	"comment" varchar(255) NULL,
	quantity int4 NOT NULL,
	reason varchar(255) NULL,
	"timestamp" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	user_id int8 NOT NULL,
	campaign_id int8 NOT NULL,
	quota_id int8 NOT NULL,
	hidden boolean
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'voucher_campaign_custom_assignment_delta');
-- TEST
SELECT * FROM api_voucher_campaign_custom_assignment_delta LIMIT 1;


-- API.voucher_campaign_quota
-----------------------------------------
DROP FOREIGN TABLE api_voucher_campaign_quota;
CREATE FOREIGN TABLE api_voucher_campaign_quota (
	id bigserial NOT NULL,
	"general" bool NULL,
	"name" varchar(255) NOT NULL,
	quantity int4 NOT NULL,
	campaign_id int8 NOT NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'voucher_campaign_quota');
-- TEST
SELECT * FROM api_voucher_campaign_quota LIMIT 1;


-- API.voucher_campaign_user_blacklist
-----------------------------------------
DROP FOREIGN TABLE api_voucher_campaign_user_blacklist;
CREATE FOREIGN TABLE api_voucher_campaign_user_blacklist (
	id bigserial NOT NULL,
	username varchar(255) NOT NULL,
	campaign_id int8 NOT NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'voucher_campaign_user_blacklist');
-- TEST
SELECT * FROM api_voucher_campaign_user_blacklist LIMIT 1;


-- API.voucher_campaign
-----------------------------------------
DROP FOREIGN TABLE api_voucher_campaign;
CREATE FOREIGN TABLE api_voucher_campaign (
	voucher_type varchar(31) NOT NULL,
	id bigserial NOT NULL,
	optlock int4 NULL,
	assignee_restriction_type varchar(255) NOT NULL,
	begin_date timestamp NOT NULL,
	code varchar(255) NOT NULL,
	creation_date timestamp NOT NULL,
	description text NULL,
	end_date timestamp NULL,
	issuer_id int8 NOT NULL,
	"name" text NULL,
	redeemer_restriction_type varchar(255) NOT NULL,
	redemption_validation_required bool NOT NULL,
	ticket_attachment_required bool NOT NULL,
	validity_period_begin_computation_type varchar(255) NOT NULL,
	validity_period_begin_fixed_date timestamp NULL,
	validity_period_begin_interval int4 NULL,
	validity_period_end_computation_type varchar(255) NOT NULL,
	validity_period_end_fixed_date timestamp NULL,
	validity_period_end_interval int4 NULL,
	bonus_percentage numeric(19, 2) NULL,
	fixed_unit_amount numeric(19, 2) NULL,
	per_user_assignable_number int4 NULL,
	total_bonus_amount numeric(19, 2) NULL,
	total_bonus_amount_limit numeric(19, 2) NULL,
	total_issuable_number int4 NULL,
	total_issuable_number_limit int4 NULL,
	image_id int8 NULL,
	suspended bool NOT NULL,
	suspension_description text NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'voucher_campaign');
-- TEST
SELECT * FROM api_voucher_campaign LIMIT 1;

	
-- API.voucher_event_log
-----------------------------------------
DROP FOREIGN TABLE api_voucher_event_log;
CREATE FOREIGN TABLE api_voucher_event_log (
	id bigserial NOT NULL,
	optlock int4 NULL,
	event_type varchar(255) NOT NULL,
	from_user_id int8 NULL,
	"timestamp" timestamp NOT NULL,
	to_user_id int8 NULL,
	transaction_context_id int8 NULL,
	voucher_id int8 NOT NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'voucher_event_log');
-- TEST
SELECT * FROM api_voucher_event_log LIMIT 1;


-- API.voucher
-----------------------------------------
DROP FOREIGN TABLE api_voucher;
CREATE FOREIGN TABLE api_voucher (
	"type" varchar(31) NOT NULL,
	id bigserial NOT NULL,
	optlock int4 NULL,
	assignee_id int8 NULL,
	assignment_date timestamp NULL,
	code varchar(255) NOT NULL,
	holder_id int8 NULL,
	issue_date timestamp NOT NULL,
	issuer_id int8 NOT NULL,
	last_transfer_date timestamp NULL,
	redeemer_id int8 NULL,
	redemption_date timestamp NULL,
	redemption_request_date timestamp NULL,
	redemption_review_comments varchar(255) NULL,
	redemption_review_date timestamp NULL,
	spend_date timestamp NULL,
	split_date timestamp NULL,
	status varchar(255) NOT NULL,
	valid_from_date timestamp NULL,
	valid_to_date timestamp NULL,
	amount numeric(19, 2) NULL,
	price numeric(19, 2) NULL,
	campaign_id int8 NOT NULL,
	parent_id int8 NULL,
	root_id int8 NULL,
	merge_date timestamp NULL,
	merge_child_id int8 NULL,
	refund_date timestamp NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'voucher');
-- TEST
SELECT * FROM api_voucher LIMIT 1;


-- API.composite_transaction_vouchers
-----------------------------------------
DROP FOREIGN TABLE api_composite_transaction_vouchers;
CREATE FOREIGN TABLE api_composite_transaction_vouchers (
	composite_transaction_id int8 NOT NULL,
	due_amount numeric(19, 2) NOT NULL,
	redeem_amount numeric(19, 2) NOT NULL,
	voucher_id int8 NOT NULL,
	item_number int4 NOT NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'composite_transaction_vouchers');
-- TEST
SELECT * FROM api_composite_transaction_vouchers LIMIT 1;


-- API.composite_transaction
-----------------------------------------
DROP FOREIGN TABLE api_composite_transaction;
CREATE FOREIGN TABLE api_composite_transaction (
	nature varchar(31) NOT NULL,
	id bigserial NOT NULL,
	optlock int4 NULL,
	currency_code varchar(255) NOT NULL,
	currency_name varchar(255) NOT NULL,
	currency_symbol varchar(255) NOT NULL,
	amount numeric(19, 2) NOT NULL,
	creation_date timestamp NOT NULL,
	description text NULL,
	payee_id int8 NOT NULL,
	payee_name varchar(255) NOT NULL,
	payee_type varchar(255) NOT NULL,
	payer_id int8 NULL,
	payer_name varchar(255) NULL,
	payer_type varchar(255) NULL,
	process_date timestamp NULL,
	due_amount numeric(19, 2) NULL,
	expiration_date timestamp NULL,
	ticket_number varchar(255) NULL,
	ticket_status varchar(255) NULL,
	ticket_type varchar(255) NULL,
	payee_operator_id int8 NULL,
	payee_operator_name varchar(255) NULL,
	payer_operator_id int8 NULL,
	payer_operator_name varchar(255) NULL,
	payee_shift_id int8 NULL,
	payer_shift_id int8 NULL,
	authorization_client_data jsonb NULL,
	refund_date timestamp NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'composite_transaction');
-- TEST
SELECT * FROM api_composite_transaction LIMIT 1;


-- API.composite_transaction_payments
-----------------------------------------
DROP FOREIGN TABLE api_composite_transaction_payments;
CREATE FOREIGN TABLE api_composite_transaction_payments (
	composite_transaction_id int8 NOT NULL,
	currency_code varchar(255) NOT NULL,
	currency_name varchar(255) NOT NULL,
	currency_symbol varchar(255) NOT NULL,
	amount numeric(19, 2) NOT NULL,
	description text NULL,
	from_account_id int8 NULL,
	from_account_name varchar(255) NULL,
	from_account_number varchar(255) NULL,
	from_user_id int8 NULL,
	from_user_name varchar(255) NULL,
	from_user_type varchar(255) NULL,
	nature varchar(255) NOT NULL,
	"number" int8 NOT NULL,
	"timestamp" timestamp NOT NULL,
	to_account_id int8 NULL,
	to_account_name varchar(255) NULL,
	to_account_number varchar(255) NULL,
	to_user_id int8 NULL,
	to_user_name varchar(255) NULL,
	to_user_type varchar(255) NULL,
	transaction_number varchar(255) NOT NULL,
	transfer_type varchar(255) NOT NULL,
	item_number int4 NOT NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'composite_transaction_payments');
-- TEST
SELECT * FROM api_composite_transaction_payments LIMIT 1;

-- API.composite_transaction_attachment
-----------------------------------------
DROP FOREIGN TABLE api_composite_transaction_attachment;
CREATE FOREIGN TABLE api_composite_transaction_attachment (
	optlock int4 NULL,
	"type" varchar(255) NOT NULL,
	file_id int8 NOT NULL,
	transaction_id int8 NOT NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'composite_transaction_attachment');
-- TEST
SELECT * FROM api_composite_transaction_attachment LIMIT 1;

-- API.stored_file
-----------------------------------------
DROP FOREIGN TABLE api_stored_file;
CREATE FOREIGN TABLE api_stored_file (
	id bigserial NOT NULL,
	optlock int4 NULL,
	contenttype varchar(100) NULL,
	"data" oid NULL,
	"name" varchar(255) NULL,
	sha256checksum varchar(255) NULL,
	sizebytes int8 NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'stored_file');
-- TEST
SELECT * FROM api_stored_file LIMIT 1;


-- API.voucher_campaign_redeemer_user_whitelist
-----------------------------------------
DROP FOREIGN TABLE api_voucher_campaign_redeemer_user_whitelist;
CREATE FOREIGN TABLE api_voucher_campaign_redeemer_user_whitelist (
	voucher_campaign_id int8 NOT NULL,
	redeemer_user_whitelist int8 NULL
) SERVER vcity_api
OPTIONS (schema_name 'public', table_name 'voucher_campaign_redeemer_user_whitelist');
-- TEST
SELECT * FROM api_voucher_campaign_redeemer_user_whitelist LIMIT 1;
