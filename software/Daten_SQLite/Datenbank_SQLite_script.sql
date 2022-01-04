/* You can't run multiple SQL statements without additional commands.
To run idividual statements:
 - highlight the entire statement and
 - press <ctrl> + <return> */
 
/*{sql Tabelle tbl_features ggf. löschen, connection=db01, include=TRUE}*/
DROP TABLE IF EXISTS tbl_features;

/*{sql Tabelle tbl_features erstellen, connection=db01, include=TRUE}*/
CREATE TABLE "tbl_features" (
	"feature_id"	INTEGER PRIMARY KEY,
	"feature_nr"	INTEGER UNIQUE NOT NULL,
	"f_name"	TEXT,
	"f_type"	TEXT,
	"f_dating"	TEXT,
	"discoverdate"	TEXT
);

/*{sql Erste Befunddaten schreiben, connection=db01}*/
INSERT INTO tbl_features (feature_nr, f_name, f_type, f_dating, discoverdate)
VALUES
(1001, 1001, 'posthole', 'not dated', '2019-05-22'),
(1002, 1002, 'pit', 'neolithic', '2019-05-22'),
(1003, 1001, 'grave', 'Corded Ware', '2019-05-22');

/*{sql Insert-Anweisung ohne die obligatorische Fundnummer, eval=FALSE, connection=db01, include=TRUE}*/
-- INSERT INTO tbl_features (f_name) VALUES (1005);  

/*{sql Anfügeabfrage ohne Attribute, error=FALSE, connection=db01}*/
INSERT INTO tbl_features VALUES (4, 1004, '1004', 'grave', 'Corded Ware', date('now'));

/*{sql Anfügeabfrage mit weiteren Daten, connection=db01}*/
INSERT INTO tbl_features (feature_nr, f_type, f_dating, discoverdate)
VALUES
(1005, 'pit', 'Late Neolithic', DATE('now')),
(1006, 'posthole', 'Neolithic', DATE('now')),
(1007, 'posthole', 'not dated', DATE('now'));

/*{sql Einfache SELECT-Anweisung, connection=db01}*/
-- SELECT 'col 1', 2, '3', 1+3, pi() AS magic;
-- although implemented in SQLite pi() gives an error.  

/*{sql Einfache Abfrage aller Befunddaten, connection=db01}*/
SELECT * FROM tbl_features;

/*{sql Abfrage für Zahlenfelder, connection=db01}*/
SELECT feature_nr, f_type, f_dating FROM tbl_features
WHERE feature_nr > 1005;

/*{sql Unscharfe Abfrage für Textfelder, connection=db01}*/
SELECT feature_nr, f_type, f_dating FROM tbl_features
WHERE ((f_type is not null) and (f_dating not like "n%"));

/*{sql Sortierte Abfrage, connection=db01}*/
SELECT feature_nr, f_name, f_type, f_dating FROM tbl_features
ORDER BY f_type DESC, feature_nr ASC;

/*{sql Gruppierte Abfrage nach der Datierung, connection=db01}*/
SELECT f_dating, count(feature_nr) AS n, group_concat(f_name, ", ") AS 'Bef.-Nr.' 
FROM tbl_features
GROUP BY f_dating; 

/*{sql Abfrage Gruppieren nach identischen feature_nr, connection=db01}*/
SELECT feature_nr, f_name as Dubletten FROM tbl_features
WHERE f_name IS NOT NULL
GROUP BY f_name
HAVING count(feature_nr) > 1;

/*{sql Fehler neolithic beheben, connection=db01}*/
UPDATE tbl_features SET f_dating = 'Neolithic' 
WHERE f_dating='neolithic';

/*{sql Filter mit *IS NULL*, connection=db01}*/
UPDATE tbl_features SET f_name = feature_nr 
WHERE f_name IS NULL;

/*{sql Abfrage der doppelten Befundnummern, connection=db01}*/
SELECT * FROM tbl_features
WHERE feature_nr IN (SELECT feature_nr FROM tbl_features
GROUP BY feature_nr
HAVING count(feature_nr) > 1);

/*{sql Doppelten Befundnummern korrigieren, connection=db01}*/
UPDATE tbl_features
SET feature_nr = 1003, f_name = '1003'
WHERE feature_id = 3;

/*{sql Löschabfrage für einen nicht vorhandenen Datensatz, connection=db01}*/
DELETE FROM tbl_features WHERE ((feature_nr <> f_name) AND (feature_id < 0));

/*{sql Tabelle für Fundkontexte ggf.löschen, connection=db01}*/
DROP TABLE IF EXISTS "tbl_findcontexts";

/*{sql Tabelle für Fundkontexte erstellen, connection=db01}*/
CREATE TABLE "tbl_findcontexts" (
	"findcontext_id"	INTEGER PRIMARY KEY,
	"find_nr" INTEGER NOT NULL,
	"feature_nr"	INTEGER NOT NULL,
	"finddate"	TEXT,
	"description"	TEXT,
	"created" TEXT DEFAULT current_date,
	FOREIGN KEY (feature_nr) REFERENCES tbl_features(feature_nr),
	CONSTRAINT "feature_find" UNIQUE (feature_nr, find_nr)
);

/*{sql Tabelle zu Datum und Zeit, connection=db01}*/
select date('now'), date('now','+1 day'), datetime('now'), 
  strftime('%s', 'now') AS 'UNIX time', julianday('now');

/*{sql Tabelle Test zu Datentypen erstellen, connection=db01}*/
create table test (i integer, t text, d integer); 

/*{sql Tabelle Test füllen, connection=db01}*/
insert into test values ('123', 123, datetime('now'));

/*{sql Tabelle Test abfragen, connection=db01}*/
select * from test;

/*{sql Tabelle Test löschen, connection=db01}*/
DROP TABLE IF EXISTS test; 

/*{sql Anfügeabfrage für die Tabelle der Fundkontexte, connection=db01}*/
INSERT INTO tbl_findcontexts (find_nr, feature_nr, finddate, description)
VALUES
(1, 1005, DATE('now'), 'surface finds'),
(2, 1005, DATE('now', '+2 day'), '1. layer'),
(3, 1005, DATE('now', '+1 month'), 'bottom layer');

/*{sql Abfrage für die Tabelle der Fundkontexte, connection=db01}*/
Select * FROM tbl_findcontexts;

/*{sql CREATE VIEW Abfrage für die Tabelle der Fundkontexte, connection=db01}*/
CREATE VIEW IF NOT EXISTS qry_findcontexts AS
Select * FROM tbl_findcontexts;

/*{sql Daten der erstellten VIEW abfragen, connection=db01}*/
Select * FROM qry_findcontexts;

/*{sql INNER JOIN Abfrage für Befunde und Funde, connection=db01}*/
SELECT a.feature_nr, a.f_type, a. f_dating, b.find_nr, b.description
FROM tbl_features AS a INNER JOIN tbl_findcontexts AS b ON a.feature_nr=b.feature_nr; 

/*{sql INNER JOIN Abfrage für Fundkontexte aus der Tabellen und der Abfrage, connection=db01}*/
SELECT a.feature_nr, a.find_nr, b.feature_nr, b.find_nr
FROM tbl_findcontexts AS a INNER JOIN qry_findcontexts AS b ON a.feature_nr=b.feature_nr; 

/*{sql LEFT JOIN Abfrage für Befunde und Funde, connection=db01}*/
SELECT a.feature_nr, a.f_type, a. f_dating, count(b.find_nr) as 'Anzahl Fundkontexte'
FROM tbl_features AS a LEFT JOIN tbl_findcontexts AS b ON a.feature_nr=b.feature_nr
GROUP BY a.feature_nr, a.f_type, a. f_dating; 

/*{sql LEFT JOIN Abfrage für Befunde ohne Fundkontexte, connection=db01}*/
SELECT a.feature_nr, a.f_type, a. f_dating
FROM tbl_features AS a LEFT JOIN tbl_findcontexts AS b ON a.feature_nr=b.feature_nr
WHERE b.find_nr IS NULL; 

/*{sql UNION ALL Abfrage für Befundinformationen, connection=db01}*/
SELECT feature_nr AS Befundnr, f_type ||", "|| f_dating AS Information, 'tbl_features' AS Tabelle
FROM tbl_features
UNION ALL
SELECT feature_nr, description, 'tbl_findcontexts'
FROM tbl_findcontexts 
ORDER BY Befundnr;

/*{sql UNION ALL Abfrage für Befunde, connection=db01}*/
SELECT feature_nr AS Befundnr, f_type AS Information
FROM tbl_features 
WHERE feature_nr < 1004
UNION
SELECT feature_nr AS Befundnr, f_type AS Information
FROM tbl_features
WHERE feature_nr < 1004;

