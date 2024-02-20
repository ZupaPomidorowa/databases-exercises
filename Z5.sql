/*
Z5 

Z5.1 - Pokazać województwa wraz ze średnią aktualna
pensją w nich (z firm tam się mieszczących)
Używając UNION, rozważyć opcję ALL
jak nie ma etatów to 0 pokazujemy
(czyli musimy obsłużyć WOJ bez etatów AKT firm)
kod_woj, nazwa (z WOJ), avg(pensja) lub 0
jak brak etatow firmowych w danym miescie

Z5.2 - to samo co w Z5.1
Ale z wykorzystaniem LEFT OUTER

Z5.3 Napisać procedurę pokazującą średnią pensję z
osób z miasta - parametr procedure @kod_woj
WYNIK:
id_miasta, nazwa (z MIASTA), avg(pensja)
czyli srednie pensje osob mieszkających w danym MIESCIE
z danego WOJ (@kod_woj)

*/

/*Z5.1*/
SELECT w.nazwa AS wojewodztwo, AVG(e.pensja) AS srednia_pensja
FROM WOJ w
JOIN MIASTA m ON m.kod_woj = w.kod_woj
JOIN FIRMY f ON m.id_miasta = f.id_miasta 
JOIN (SELECT et.id_firmy, et.pensja FROM ETATY et WHERE et.do IS NULL) e ON f.nazwa_skr = e.id_firmy
GROUP BY w.nazwa
UNION ALL
SELECT w.nazwa, 
ISNULL( CONVERT (money, null), 0) 
FROM WOJ w
WHERE NOT EXISTS 
(SELECT 1
FROM MIASTA m, FIRMY f, ETATY e
WHERE m.kod_woj = w.kod_woj AND
	m.id_miasta = f.id_miasta AND
	f.nazwa_skr = e.id_firmy AND 
	e.do IS NULL)

/*
wojewodztwo			srednia_pensja
LUBELSKIE			2066.6666
MAZOWIECKIE			4000.00
OPOLSKIE			3750.00
POMORSKIE			3750.00
ZACHODNIOPOMORSKIE	9600.00
PODLASKIE			0.00
WIELKOPOLSKIE		0.00
*/

/*Z5.2*/
SELECT w.nazwa AS wojewodztwo, ISNULL(X.srednia, 0) AS srednia_pensja
FROM WOJ w
left outer
JOIN
(SELECT m.kod_woj, AVG(e.pensja) AS srednia
FROM MIASTA m, FIRMY f, ETATY e
WHERE m.id_miasta = f.id_miasta AND
	f.nazwa_skr = e.id_firmy AND 
	e.do IS NULL
GROUP BY m.kod_woj) X
ON X.kod_woj = w.kod_woj

/*
wojewodztwo			srednia_pensja
LUBELSKIE			2066.6666
MAZOWIECKIE			4000.00
OPOLSKIE			3750.00
PODLASKIE			0.00
POMORSKIE			3750.00
WIELKOPOLSKIE		0.00
ZACHODNIOPOMORSKIE	9600.00
*/

/*Z5.3*/
CREATE PROC buka @kod_woj nchar(4)
AS

SELECT m.id_miasta, m.nazwa, m.kod_woj, AVG(e.pensja) AS srednia
FROM MIASTA m
JOIN FIRMY f ON m.id_miasta = f.id_miasta 
JOIN ETATY e ON f.nazwa_skr = e.id_firmy
WHERE m.kod_woj = @kod_woj
GROUP BY m.nazwa, m.id_miasta, m.kod_woj
UNION ALL
SELECT m.id_miasta, m.nazwa, m.kod_woj, ISNULL(CONVERT (money, null), 0) 
FROM MIASTA m
WHERE 	m.kod_woj = @kod_woj AND
NOT EXISTS
(SELECT 1
FROM FIRMY f, ETATY e
WHERE f.id_miasta = m.id_miasta AND
	f.nazwa_skr = e.id_firmy AND
	e.do IS NULL)
GO

EXEC buka N'OPL'

/*
id_miasta	nazwa	kod_woj		srednia
4			Opole	OPL 		1500.00
5			Suwałki	OPL 		6000.00
*/