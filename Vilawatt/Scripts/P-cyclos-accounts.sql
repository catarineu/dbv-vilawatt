SELECT * FROM transfers limit 10;
SELECT * FROM account_balances ab limit 10;

-- ======================================
-- CONSULTA saldo d'un compte 
SELECT
	u.id AS ac_id, u."name" AS nom, "number" AS ac_number, a.id AS ac_id, ab.balance 
FROM
	accounts a
	LEFT OUTER JOIN account_balances ab ON (ab.account_id=a.id)
	LEFT OUTER JOIN users u ON (u.id=a.user_id)
WHERE
	user_id = 24
LIMIT 10;

-- ======================================
-- CONSULTA moviments CYCLOS amb detalls
SELECT
	a.id AS ac_id, tt.name AS t_type, u1.name AS from_name, u2."name" AS to_name,
	t.amount AS t_amount,  t."date", t.subclass,
	t.transaction_number AS t_txnum, u1.id AS from_id, u2.id AS to_id, t.id AS pay_id
FROM
	accounts a 
	LEFT OUTER JOIN transfers t ON (t.from_id=a.id OR t.to_id=a.id)
	LEFT OUTER JOIN transfer_types tt ON (t.type_id=tt.id)
	LEFT OUTER JOIN accounts a1 ON (a1.id=t.from_id)
	LEFT OUTER JOIN accounts a2 ON (a2.id=t.to_id)
	LEFT OUTER JOIN users u1 ON (u1.id=a1.user_id)
	LEFT OUTER JOIN users u2 ON (u2.id=a2.user_id)
WHERE
	date > '2022-01-01' 
	AND a.user_id = 1754
ORDER BY
	date DESC;

-- ======================================
-- FUSIÓ: CONSULTA moviments CYCLOS 
SELECT
	t."date", u1.name||' ('||u1.id||')' AS payer, u2."name"||' ('||u2.id||')' AS payee, tt.name AS t_type, 
	t.amount AS amount, t.amount AS w_saldo, 0 AS w_bons, NULL AS bons, 
	u1.user_group_id AS payer_group, u2.user_group_id AS payee_group, 
	t.subclass ||',  tx='|| t.transaction_number ||',  tid='|| t.id AS details
FROM
	accounts a 
	LEFT OUTER JOIN transfers t ON (t.from_id=a.id OR t.to_id=a.id)
	LEFT OUTER JOIN transfer_types tt ON (t.type_id=tt.id)
	LEFT OUTER JOIN accounts a1 ON (a1.id=t.from_id)
	LEFT OUTER JOIN accounts a2 ON (a2.id=t.to_id)
	LEFT OUTER JOIN users u1 ON (u1.id=a1.user_id)
	LEFT OUTER JOIN users u2 ON (u2.id=a2.user_id)
WHERE
	date > '2022-01-01' 
	AND a.user_id = 1754
ORDER BY
	date DESC;

