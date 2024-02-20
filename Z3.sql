/* Z3
Z3.1 - policzyc liczbe stanowisk w ETATY (zapytanie z grupowaniem w wyniku STANOWISKO, LICZBA_ST)
Najlepiej wynik zapamietac w tabeli tymczasowej

Z3.2 - korzystajac z wyniku Z3,1 - pokazac, które STANOWISKO najczesciejciej wystepuje
(zapytanie z fa - analogiczne do zadan z Z2)

Z3.3 Pokazac liczbe firm w kazdym z województw (czyli grupowanie po kod_woj)
Z3.4 Poazc województwa w których nie ma zadnej firmy

(suma z3.3 i z3.4 powinna daæ nam pelna liste województw - woj gdzie sa firmy i gdzie ich nie ma to razem powinny byc wszystkie
*/



CREATE TABLE #tabela
(
STANOWISKO varchar(50),
LICZBA_ST int
)
INSERT INTO #tabela SELECT stanowisko AS STANOWISKO, COUNT(*) AS LICZBA_ST  FROM ETATY GROUP BY stanowisko
SELECT * FROM #tabela


/*
STANOWISKO	LICZBA_ST
---------	---------
Barista		1
Dostawca	1
Kasjer		6
Ksiegowa	2
Ksiegowy	1
Logistyk	1
Piekarz		2
Piekarz		1
Prezes		1
Sprzedawca	6
*/



SELECT stanowisko AS STANOWISKO , COUNT(*) AS LICZBA_ST  FROM ETATY GROUP BY stanowisko HAVING COUNT(*) = (SELECT MAX(a.cnt) FROM
(SELECT COUNT(*) AS cnt FROM  ETATY GROUP BY (stanowisko)) AS a)


/*
STANOWISKO	LICZBA_ST
--------	----------
Kasjer		6
Sprzedawca	6
*/

SELECT COUNT(*) AS liczba_firm, w.nazwa AS wojewodztwo FROM FIRMY f, MIASTA m, WOJ w 
WHERE f.id_miasta = m.id_miasta and m.kod_woj = w.kod_woj GROUP BY w.nazwa

/*
liczba_firm		wojewodztwo
1				LUBELSKIE
4				MAZOWIECKIE
2				OPOLSKIE
2				POMORSKIE
5				ZACHODNIOPOMORSKIE

Wersja 2 z grupowaniem po kod_woj
SELECT COUNT(*) AS liczba_firm, m.kod_woj FROM FIRMY f, MIASTA m
WHERE f.id_miasta = m.id_miasta GROUP BY m.kod_woj


liczba_firm		kod_woj
1				LUBE
4				MAZ 
2				OPL 
2				POM 
5				ZPOM
*/


SELECT w1.nazwa AS wojewodztwa_bez_firm, w1.kod_woj FROM WOJ w1 WHERE w1.nazwa NOT IN (SELECT w2.nazwa
FROM FIRMY f, MIASTA m, WOJ w2 WHERE f.id_miasta = m.id_miasta and m.kod_woj = w2.kod_woj GROUP BY w2.nazwa)

/*
wojewodztwa_bez_firm	kod_woj
PODLASKIE				POD 
WIELKOPOLSKIE			WLKP
*/
