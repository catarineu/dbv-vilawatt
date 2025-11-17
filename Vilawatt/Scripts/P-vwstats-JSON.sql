CREATE TABLE  tjson2 (lotid varchar, dades jsonb);

INSERT INTO tjson2 VALUES ('CYR01-22-0731-238882','[{"type": "Ruby", "carats": 1.88, "origins": ["MOZ"]}, {"type": "Orange Sapphire", "carats": 5.58, "origins": ["MDG", "TZS"]}, {"type": "Yellow Sapphire", "carats": 4.53, "origins": ["MDG", "TZS", "LKA"]}, {"type": "Green Sapphire", "carats": 2.83, "origins": ["MDG", "TZS"]}, {"type": "Blue Sapphire", "carats": 6.92, "origins": ["MDG", "AUS"]}, {"type": "Tsavorite Garnet", "carats": 6.28, "origins": ["TZA", "KEN"]}]');

SELECT * FROM tjson t ;
SELECT json_array_elements(dades::json)->'origins' FROM tjson t ;

WITH dad AS (
	SELECT
		lotid,
		REPLACE(json_array_elements(json_array_elements(dades::json)->'origins')::TEXT,'"','') AS origin
	FROM
		tjson2 t )
SELECT * FROM dad
WHERE origin='MDG';