/*
 Z4 
Z4.1 - pokazać firmy z miasta o kodzie X, w których nigdy
nie pracowały / nie pracują (ignorujemy kolumny OD i DO) osoby mieszkające w mieście o kodzie id_miasta=Y (zapytanie z NOT EXISTS)
Czyli jak FIRMA PW ma 2 etaty i jeden
osoby mieszkającej w mieście o ID= X
a drugi etat osoby mieszkającej w mieście o ID=Y
to takiej FIRMY NIE POKOZUJEMY !!!
A nie, że pokażemy jeden etat a drugi nie
Z4.2 - pokazać liczbę firm w MIASTO. Ale tylko takie mające więcej jak jedną firmę

Z4,3 - pokazać średnią pensję w MIASTA ale MIAST posiadających więcej jak jedną firmę
Srednia w miastach może być liczona z osób tam mieszkających lub firm tam będących
1 wariant -> etaty -> osoby
teraz złaczamy wynik tego zapytania z FIRMY (grupowane po ID_MIASTA z HAVING)
2 wariant -> (średnia z firm o danym id_miasta)
(łaczymy wynik z FIRMY -> grupowaniem poprzez ID_MIASTA)

*/

SELECT f.nazwa AS FIRMA
FROM FIRMY f
WHERE f.id_miasta = 7 AND NOT EXISTS
(
SELECT 1 FROM ETATY e, OSOBY o
WHERE e.id_osoby = o.id_osoby AND
	  e.id_firmy = f.nazwa_skr AND
	  o.id_miasta = 2
)

/*
FIRMA
Firma
Sklep 2
*/

SELECT m.nazwa AS miasto, COUNT(*) AS liczba_firm
FROM MIASTA m
JOIN FIRMY f ON f.id_miasta = m.id_miasta
GROUP BY m.nazwa
HAVING COUNT(*) > 1

/*
miasto		liczba_firm
Gdynia		2
Koniec		2
Szczecin	2
Warszawa	3
*/

SELECT m.nazwa, AVG(e.pensja) AS srednia_pensja_po_firmach
FROM MIASTA m
JOIN FIRMY f ON m.id_miasta = f.id_miasta 
JOIN ETATY e ON f.nazwa_skr = e.id_firmy
GROUP BY m.nazwa

/*
nazwa		srednia_pensja_po_firmach
Gdynia		3750.00
Koniec		9600.00
Warszawa	4785.7142
*/