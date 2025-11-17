-- CREATION: cyclos.id_cipher_rounds
-----------------------------------------
--DROP FOREIGN TABLE cyclos_id_cipher_rounds;
CREATE FOREIGN TABLE cyclos_id_cipher_rounds (
	id bigserial NOT NULL,
	mask int8 NOT NULL,
	order_index int4 NOT NULL,
	rotate_bits int4 NOT NULL
) server vcity_cyclos
OPTIONS (schema_name 'public', table_name 'id_cipher_rounds');
-- TEST
select * from cyclos_id_cipher_rounds limit 1;

-- CREATION: cyclos.users
-----------------------------------------
--DROP FOREIGN TABLE cyclos_users;
CREATE FOREIGN TABLE cyclos_users (
	id bigserial NOT NULL,
	subclass varchar(31) NULL,
	creation_date timestamp NOT NULL,
	display varchar(255) NULL,
	email varchar(255) NULL,
	"name" varchar(200) NULL,
	new_email varchar(255) NULL,
	password_statuses text NULL,
	registration_confirmation_date timestamp NULL,
	registration_type varchar(255) NULL,
	security_answer text NULL,
	security_question varchar(255) NULL,
	send_activation_email bool NULL,
	short_display varchar(255) NULL,
	status varchar(255) NULL,
	username varchar(255) NOT NULL,
	validation_key varchar(255) NULL,
	validation_key_date timestamp NULL,
	validation_key_type varchar(255) NULL,
	"version" int4 NOT NULL,
	network_id int8 NULL,
	registered_by_id int8 NULL,
	operator_group_id int8 NULL,
	operator_user_id int8 NULL,
	accepted_agreement_ids text NULL,
	user_activation_date timestamp NULL,
	user_hide_email bool NULL,
	individual_product_ids text NULL,
	user_group_id int8 NULL,
	image_id int8 NULL,
	name_tsvector tsvector NULL,
	username_tsvector tsvector null
) server vcity_cyclos
OPTIONS (schema_name 'public', table_name 'users');
-- TEST
select * from cyclos_users limit 1;

-- CREATION: cyclos.user_custom_fields
-----------------------------------------
-- DROP FOREIGN TABLE cyclos_user_custom_fields;
CREATE FOREIGN TABLE cyclos_user_custom_fields (
	id bigserial NOT NULL,
	all_selected_label varchar(255) NULL,
	allowed_mime_types text NULL,
	"control" varchar(255) NOT NULL,
	decimal_digits int4 NULL,
	default_boolean_value bool NULL,
	default_date_today bool NULL,
	default_date_value timestamp NULL,
	default_decimal_value numeric NULL,
	default_integer_value int4 NULL,
	default_rich_text_value text NULL,
	default_string_value varchar(4000) NULL,
	default_text_value text NULL,
	description text NULL,
	exact_match bool NOT NULL,
	expanded_categories bool NOT NULL,
	hidden_by_default bool NULL,
	ignore_sanitizer bool NOT NULL,
	include_in_csv bool NULL,
	information_text text NULL,
	internal_name varchar(50) NULL,
	linked_entity_type varchar(255) NULL,
	load_values_script_parameters text NULL,
	max_files int4 NULL,
	max_word_size int4 NULL,
	"name" varchar(100) NOT NULL,
	order_index int4 NOT NULL,
	other_mime_types text NULL,
	pattern varchar(255) NULL,
	val_required bool NOT NULL,
	"size" varchar(255) NULL,
	"type" varchar(255) NOT NULL,
	val_unique bool NOT NULL,
	validation_script_parameters text NULL,
	"version" int4 NOT NULL,
	max_decimal_value numeric NULL,
	min_decimal_value numeric NULL,
	max_integer_value int4 NULL,
	min_integer_value int4 NULL,
	val_max_length int4 NULL,
	val_min_length int4 NULL,
	load_values_script_id int8 NULL,
	network_id int8 NOT NULL,
	validation_script_id int8 NULL,
	purge_values bool NULL,
	storage_directory varchar(255) NULL
	) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'user_custom_fields');
-- TEST
SELECT * FROM cyclos_user_custom_fields LIMIT 1;

-- CREATION: cyclos.user_custom_field_values
-----------------------------------------
-- DROP FOREIGN TABLE cyclos_user_custom_field_values;
CREATE FOREIGN TABLE cyclos_user_custom_field_values (
	id bigserial NOT NULL,
	boolean_value bool NULL,
	date_value timestamp NULL,
	decimal_value numeric NULL,
	hidden bool NOT NULL,
	integer_value int4 NULL,
	linked_entity_id int8 NULL,
	rich_text_value text NULL,
	string_value varchar(4000) NULL,
	text_value text NULL,
	"version" int4 NOT NULL,
	field_id int8 NOT NULL,
	owner_id int8 NOT NULL,
	value_tsvector tsvector NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'user_custom_field_values');
-- TEST
SELECT * FROM cyclos_user_custom_field_values LIMIT 1;


-- CREATION: cyclos_user_custom_field_possible_values
-----------------------------------------
-- DROP FOREIGN TABLE public.cyclos_user_custom_field_possible_values;
CREATE FOREIGN TABLE public.cyclos_user_custom_field_possible_values (
	id bigserial NOT NULL,
	default_value bool NULL,
	internal_name varchar(50) NULL,
	order_index int4 NOT NULL,
	value text NULL,
	"version" int4 NOT NULL,
	category_id int8 NULL,
	field_id int8 NOT NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'user_custom_field_possible_values');
-- TEST
SELECT * FROM cyclos_user_custom_field_possible_values LIMIT 1;

-- CREATION: cyclos.cyclos_user_status_logs
-----------------------------------------
-- DROP FOREIGN TABLE public.cyclos_user_status_logs;
CREATE FOREIGN TABLE public.cyclos_user_status_logs (
	id bigserial NOT NULL,
	"comment" text NULL,
	end_date timestamp NULL,
	start_date timestamp NOT NULL,
	status varchar(255) NOT NULL,
	by_id int8 NULL,
	user_id int8 NOT NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'user_status_logs');
-- TEST
SELECT * FROM cyclos_user_status_logs LIMIT 1;


-- CREATION: cyclos_user_enum_values
-----------------------------------------
-- DROP FOREIGN TABLE cyclos_user_enum_values;
CREATE FOREIGN TABLE cyclos_user_enum_values (
	owner_id int8 NOT NULL,
	possible_value_id int8 NOT NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'user_enum_values');
-- TEST
SELECT * FROM cyclos_user_enum_values LIMIT 1;





-- CREATION: cyclos_groups
-----------------------------------------
-- DROP FOREIGN TABLE cyclos_groups;
CREATE FOREIGN TABLE cyclos_groups (
	id bigserial NOT NULL,
	subclass varchar(31) NULL,
	description text NULL,
	internal_name varchar(50) NULL,
	name varchar(100) NOT NULL,
	"version" int4 NOT NULL,
	configuration_id int8 NOT NULL,
	network_id int8 NULL,
	enabled bool NULL,
	initial_user_status varchar(255) NULL,
	admin_group_type varchar(255) NULL,
	admin_max_registered_networks int4 NULL,
	admin_product_id int8 NULL,
	inherits_configuration bool NULL,
	initial_group_description text NULL,
	initial_group_display_name varchar(255) NULL,
	move_users_automatically bool NULL,
	move_users_after_period_amount int4 NULL,
	move_users_after_period_field varchar(255) NULL,
	group_set_id int8 NULL,
	move_users_to_group_id int8 NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'groups');
-- TEST
SELECT * FROM cyclos_groups LIMIT 1;

	
-- CREATION: cyclos_accounts
-----------------------------------------
-- DROP FOREIGN TABLE cyclos_accounts;
CREATE FOREIGN TABLE cyclos_accounts (
	id bigserial NOT NULL,
	subclass varchar(31) NULL,
	creation_date timestamp NOT NULL,
	last_balance_closing_date timestamp NULL,
	negative_since timestamp NULL,
	"number" varchar(255) NULL,
	account_type_id int8 NOT NULL,
	user_id int8 NULL,
	account_rates_id int8 NULL,
	user_active bool NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'accounts');
-- TEST
SELECT * FROM cyclos_accounts LIMIT 1;

-- CREATION: cyclos_account_balances
-----------------------------------------
-- DROP FOREIGN TABLE cyclos_account_balances;
CREATE FOREIGN TABLE cyclos_account_balances (
	balance numeric NOT NULL,
	reserved numeric NOT NULL,
	transfer_id int8 NOT NULL,
	account_id int8 NOT NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'account_balances');
-- TEST
SELECT * FROM cyclos_account_balances LIMIT 1;

-- CREATION: cyclos_transfers
-----------------------------------------
-- DROP FOREIGN TABLE cyclos_transfers;
CREATE FOREIGN TABLE cyclos_transfers (
	id bigserial NOT NULL,
	subclass varchar(31) NULL,
	amount numeric NOT NULL,
	"date" timestamp NOT NULL,
	emission_date timestamp NULL,
	expiration_date timestamp NULL,
	transaction_number varchar(255) NULL,
	from_id int8 NOT NULL,
	parent_id int8 NULL,
	to_id int8 NOT NULL,
	transaction_id int8 NULL,
	type_id int8 NOT NULL,
	charged_back_by_id int8 NULL,
	user_account_fee_log_id int8 NULL,
	chargeback_of_id int8 NULL,
	"number" int4 NULL,
	scheduled_payment_installment_id int8 NULL,
	transfer_fee_id int8 NULL,
	processed_by_id int8 NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'transfers');
-- TEST
SELECT * FROM cyclos_transfers LIMIT 1;

-- CREATION: cyclos_transfer_types
-----------------------------------------
-- DROP FOREIGN TABLE cyclos_transfer_types;
CREATE FOREIGN TABLE cyclos_transfer_types (
	id bigserial NOT NULL,
	subclass varchar(31) NULL,
	description text NULL,
	direction varchar(255) NOT NULL,
	ignore_account_limits bool NULL,
	internal_name varchar(50) NULL,
	"name" varchar(100) NOT NULL,
	notify_payment_received bool NULL,
	value_for_empty_description text NULL,
	"version" int4 NOT NULL,
	from_account_type_id int8 NOT NULL,
	to_account_type_id int8 NOT NULL,
	dratecreationvalue_id int8 NULL,
	confirmation_message text NULL,
	enabled bool NULL,
	maturity_history_size int4 NULL,
	maturity_policy varchar(255) NULL,
	requires_authorization bool NULL,
	max_chargeback_time_amount int4 NULL,
	max_chargeback_time_field varchar(255) NULL,
	allow_from_custom_name bool NULL,
	allow_to_custom_name bool NULL,
	allows_recurring_payments bool NULL,
	allows_scheduled_payments bool NULL,
	default_feedback_comments varchar(255) NULL,
	transaction_default_feedback_level varchar(255) NULL,
	transaction_feedback_enabled_since timestamp NULL,
	transaction_feedback_expiration_days int4 NULL,
	transaction_feedback_expiration_reminder_days int4 NULL,
	transaction_feedback_reminder_days int4 NULL,
	transaction_feedback_reply_expiration_days int4 NULL,
	transaction_feedback_setting varchar(255) NULL,
	payment_max_amount numeric NULL,
	payment_max_amount_per_day numeric NULL,
	payment_max_amount_per_day_pinless numeric NULL,
	payment_max_amount_per_month numeric NULL,
	payment_max_amount_per_week numeric NULL,
	payment_max_amount_pinless numeric NULL,
	max_days_to_change_feedback int4 NULL,
	max_installments int4 NULL,
	payment_max_transfers_per_day int4 NULL,
	payment_max_transfers_per_month int4 NULL,
	payment_max_transfers_per_week int4 NULL,
	payment_min_amount numeric NULL,
	payment_priority bool NULL,
	transaction_requires_feedback bool NULL,
	reserve_total_amount_on_scheduled_payments bool NULL,
	payment_restrict_to varchar(255) NULL,
	show_recurring_payments_to_receiver bool NULL,
	show_scheduled_payments_to_receiver bool NULL,
	request_default_expiration_interval_amount int4 NULL,
	request_default_expiration_interval_field varchar(255) NULL,
	min_time_between_transfers_amount int4 NULL,
	min_time_between_transfers_field varchar(255) NULL,
	display_template varchar(255) NULL,
	hide_payment_request_expiration bool NULL,
	lock_from bool NULL,
	lock_to bool NULL,
	description_availability varchar(255) NOT NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'transfer_types');
-- TEST
SELECT * FROM cyclos_transfer_types LIMIT 1;


-- CYCLOS.stored_file
-----------------------------------------
DROP FOREIGN TABLE cyclos_login_history_logs;
CREATE FOREIGN TABLE cyclos_login_history_logs (
	id bigserial NOT NULL,
	date_time timestamp NOT NULL,
	remote_address varchar(255) NULL,
	user_id int8 NOT NULL
) SERVER vcity_cyclos
OPTIONS (schema_name 'public', table_name 'login_history_logs');
-- TEST
SELECT * FROM cyclos_login_history_logs LIMIT 1;





