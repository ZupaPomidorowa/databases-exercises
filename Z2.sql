/*

1.Pokazać dane podstawowe osoby, w jakim mieście mieszka i w jakim to jest województwie

2.Pokazać wszystkie etaty o STANOWISKU na literę P i ostatniej literze STANOWISKA s lub a
które mają pensje pomiędzy 3000 a 5000 (też możecie zmienić jeżeli macie głownie inne zakresy)
mieszkajace w innym mieście niż znajduje się firma, w której mają etat
(wystarczą dane z tabel etaty, firmy, osoby , miasta)

3.Pokazać które miasto ma najdłuższą nazwę w bazie
(najpierw szukamy MAX z LEN(NAZWA)
a potem pokazujemy te miasta z taką długością pola NAZWA)

4.Policzyć liczbę etatów w firmie o nazwie (tu daję Wam wybór)
*/

SELECT osoby.imie, osoby.nazwisko, miasta.nazwa AS miasto, woj.nazwa AS wojewodztwo 
FROM OSOBY, MIASTA, WOJ 
WHERE osoby.id_miasta = miasta.id_miasta AND miasta.kod_woj = woj.kod_woj

/*
imie		nazwisko		miasto		wojewodztwo
-------		----------		-------		-------------
Jacek		Korytkowski		Grodzisk	MAZOWIECKIE
Adam		Kowalski		Grodzisk	MAZOWIECKIE
Beata		Kowalska		Grodzisk	MAZOWIECKIE
Michał		Nowak			Krasnystaw	LUBELSKIE
Ania		Nowak			Krasnystaw	LUBELSKIE
Julka		Piskorska		Opole		OPOLSKIE
Krysia		Nowacka			Opole		OPOLSKIE
Andrzej		Piatkowski		Suwałki		OPOLSKIE
Karolina	Pawłowicz		Suwałki		OPOLSKIE
Karol		Okoński			Gdynia		POMORSKIE
Zuzanna		Piskorska		Gdynia		POMORSKIE
Artur		Janczewski		Koniec		ZACHODNIOPOMORSKIE
Filip		Jagiełło		Koniec		ZACHODNIOPOMORSKIE
Marcin		Pietruk			Szczecin	ZACHODNIOPOMORSKIE
Beata		Pietrk			Szczecin	ZACHODNIOPOMORSKIE
Artur		Kapuściński		Koszalin	ZACHODNIOPOMORSKIE
*/


SELECT e.stanowisko, STR(e.pensja, 5,0) AS pensja, mo.nazwa AS miasto_zamieszkania, mf.nazwa AS miasto_firma
FROM ETATY e 
JOIN OSOBY o ON (o.id_osoby = e.id_osoby)
JOIN FIRMY f ON (e.id_firmy = f.nazwa_skr)
JOIN MIASTA mo ON (o.id_miasta = mo.id_miasta)
JOIN MIASTA mf ON (f.id_miasta = mf.id_miasta)
WHERE e.stanowisko LIKE N'P%' AND 
(e.stanowisko LIKE N'%s' OR e.stanowisko LIKE N'%a') AND
e.pensja BETWEEN 3000 AND 5000 AND 
mo.nazwa != mf.nazwa

/*
stanowisko	pensja	miasto_zamieszkania		miasto_firma
----------	------	-------------------		-------------
Piekarza	3500	Grodzisk				Warszawa
Pączkarza	3200	Grodzisk				Krasnystaw
*/

SELECT MIASTA.nazwa, LEN(MIASTA.nazwa) AS dlugosc FROM MIASTA WHERE LEN(nazwa) = (SELECT MAX(LEN(nazwa)) FROM MIASTA)

/*
nazwa		dlugosc
Krasnystaw	10

Wszystkie miasta wraz z ich dlugoscia
SELECT m.nazwa, LEN(m.nazwa) AS dlugosc FROM MIASTA m
nazwa		dlugosc
--------	-------
Warszawa	8
Grodzisk	8
Krasnystaw	10
Opole		5
Suwałki		7
Gdynia		6
Koniec		6
Szczecin	8
Koszalin	8

*/

SELECT N'Donuty' AS firma, COUNT(*) AS etaty FROM ETATY e JOIN FIRMY f ON (e.id_firmy = f.nazwa_skr) WHERE f.nazwa = N'Donuty'
/*
firma	etaty
Donuty	3

Z tabeli ETATY etaty z firmy Donuty
id_osoby	id_firmy	stanowisko		pensja		od			do			id_etatu
----------	---------	----------		-------		----------	----------	---------
3			DON  		Kasjer			1500.00		2022-01-16	NULL		7
4			DON  		Kasjer			1500.00		2021-01-16	NULL		8
2			DON  		Pączkarz		3200.00		2017-04-25	NULL		22
*/



IF OBJECT_ID(N'ETATY') IS NOT NULL
	DROP TABLE ETATY
GO
IF OBJECT_ID(N'OSOBY') IS NOT NULL
	DROP TABLE OSOBY
GO
IF OBJECT_ID(N'FIRMY') IS NOT NULL
	DROP TABLE FIRMY
GO
IF OBJECT_ID(N'MIASTA') IS NOT NULL
	DROP TABLE MIASTA
GO
IF OBJECT_ID(N'WOJ') IS NOT NULL
	DROP TABLE WOJ
GO

CREATE TABLE dbo.WOJ 
(	kod_woj nchar(4)	NOT NULL CONSTRAINT PK_WOJ PRIMARY KEY
,	nazwa	nvarchar(50) NOT NULL
)
GO
CREATE TABLE dbo.MIASTA
(	id_miasta	int				not null IDENTITY CONSTRAINT PK_MIASTA PRIMARY KEY
,	nazwa		nvarchar(50)	NOT NULL
,	kod_woj		nchar(4)		NOT NULL 
	CONSTRAINT FK_MIASTA_WOJ FOREIGN KEY REFERENCES WOJ(kod_woj)
/* klucz obcy to powiązanie do lucza głownego w innej tabelce
** typy kolumn muszą się zgadzac - nazwy nie muszą */ 
)
GO
CREATE TABLE dbo.OSOBY
(id_osoby int NOT NULL IDENTITY	CONSTRAINT PK_OSOBY PRIMARY KEY	
,	id_miasta	int				not null CONSTRAINT FK_OSOBY_MIASTA FOREIGN KEY
		REFERENCES MIASTA(id_miasta)
,	imie		nvarchar(50)	NOT NULL
,	nazwisko	nvarchar(50)	NOT NULL 
	
/* klucz obcy to powiązanie do lucza głownego w innej tabelce
** typy kolumn muszą się zgadzac - nazwy nie muszą */ 
)
GO
CREATE TABLE dbo.FIRMY
(
nazwa_skr nchar(5) NOT NULL CONSTRAINT PK_FIRMY PRIMARY KEY,
id_miasta int    not null CONSTRAINT FK_FIRMY_MIASTA FOREIGN KEY REFERENCES MIASTA(id_miasta) ,
nazwa nvarchar(50) NOT NULL,
kod_pocztowy  nchar(6)  NOT NULL, 
ulica nvarchar(50) NOT NULL
)
GO
CREATE TABLE dbo.ETATY
(
id_osoby int not null CONSTRAINT FK_ETATY_OSOBY FOREIGN KEY REFERENCES OSOBY(id_osoby) ,
id_firmy nchar(5) NOT NULL CONSTRAINT FK_ETATY_FIRMY FOREIGN KEY REFERENCES FIRMY(nazwa_skr) ,
stanowisko nvarchar(50) NOT NULL,
pensja money NOT NULL,
od date NOT NULL,
do date NULL,
id_etatu int NOT NULL IDENTITY CONSTRAINT PK_ETATY PRIMARY KEY
)
GO


INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'MAZ', N'MAZOWIECKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'LUBE', N'LUBELSKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'OPL', N'OPOLSKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'POD', N'PODLASKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'POM', N'POMORSKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'WLKP', N'WIELKOPOLSKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'ZPOM', N'ZACHODNIOPOMORSKIE')


DECLARE @id_wa int, @id_jk int

INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Warszawa', N'MAZ')
SET @id_wa = SCOPE_IDENTITY() /* zwraca jakie ID nadano automatycznie w poprzednim poleceniu */

DECLARE @id_gro int, @id_kra int, @id_op int, @id_su int, @id_gdy int, @id_ks int, @id_szcz int, @id_kos int

INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Grodzisk', N'MAZ')
SET @id_gro = SCOPE_IDENTITY() 
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Krasnystaw', N'LUBE')
SET @id_kra = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Opole', N'OPL')
SET @id_op = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Suwałki', N'OPL')
SET @id_su = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Gdynia', N'POM')
SET @id_gdy = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Koniec', N'ZPOM')
SET @id_ks = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Szczecin', N'ZPOM')
SET @id_szcz = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Koszalin', N'ZPOM')
SET @id_kos = SCOPE_IDENTITY()


INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'PACZ', @id_wa, N'Pączkarnia', N'02-456', N'Chmielna 10')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'PIE', @id_wa, N'Pierogarnia', N'02-422', N'Nowa')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'PIEK', @id_wa, N'Piekarnia', N'03-121', N'Wesoła')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'SPACZ', @id_gro, N'Stara Pączkarnia', N'01-003', N'Tłusta')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'DON', @id_kra, N'Donuty', N'03-778', N'Truskawkowa')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'MPACZ', @id_op, N'Mini Pączki', N'98-234', N'Lukrowa')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'NPACZ', @id_su, N'Najlepsze Pączki', N'76-545', N'Berylowa')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'KAW', @id_gdy, N'Kawiarnia', N'76-890', N'Cukrowa')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'SKL', @id_gdy, N'Sklep', N'23-456', N'Sklepowa')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'SKL2', @id_ks, N'Sklep 2', N'45-112', N'Sklepna')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'FIR', @id_ks, N'Firma', N'45-113', N'Firmowa')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'FIR2', @id_szcz, N'Firma 2', N'55-890', N'Firmna') 
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'NFIRM', @id_szcz, N'Najlepsza Firma', N'43-908', N'Fir') 
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'PIE2', @id_kos, N'Piekrania 2', N'33-489', N'Piekarnicza') 

DECLARE @id_ad int,	@id_bk int,	@id_mk int,	@id_an int,	@id_jp int,
		@id_kn int,	@id_ap int,	@id_kp int,	@id_ko int,	@id_zp int,
		@id_aj int,	@id_fj int,	@id_mp int,	@id_bp int,	@id_ak int

INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_gro, N'Jacek' , N'Korytkowski')
SET @id_jk = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_gro, N'Adam' , N'Kowalski')
SET @id_ad = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_gro, N'Beata' , N'Kowalska')
SET @id_bk = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_kra, N'Michał' , N'Nowak')
SET @id_mk = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_kra, N'Ania' , N'Nowak')
SET @id_an = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_op, N'Julka' , N'Piskorska')
SET @id_jp = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_op, N'Krysia' , N'Nowacka')
SET @id_kn = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_su, N'Andrzej' , N'Piatkowski')
SET @id_ap = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_su, N'Karolina' , N'Pawłowicz')
SET @id_kp = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_gdy, N'Karol' , N'Okoński')
SET @id_ko = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_gdy, N'Zuzanna' , N'Piskorska')
SET @id_zp = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_ks, N'Artur' , N'Janczewski')
SET @id_aj = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_ks, N'Filip' , N'Jagiełło')
SET @id_fj = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_szcz, N'Marcin' , N'Pietruk')
SET @id_mp = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_szcz, N'Beata' , N'Pietrk')
SET @id_bp = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_kos, N'Artur' , N'Kapuściński') 
SET @id_ak = SCOPE_IDENTITY()

DECLARE @id_et1 int, @id_et2 int, @id_et3 int, @id_et4 int, @id_et5 int, @id_et6 int, @id_et7 int, @id_et8 int, @id_et9 int, @id_et10 int, @id_et11 int,
		@id_et12 int, @id_et13 int, @id_et14 int, @id_et15 int, @id_et16 int, @id_et17 int, @id_et18 int, @id_et19 int, @id_et20 int, @id_et21 int, @id_et22 int

INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_jk, N'PACZ',N'Sprzedawca', 5000, CONVERT(datetime, '20190302', 112), CONVERT(datetime, '20200302', 112) )
SET @id_et1 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_jk, N'PIE', N'Sprzedawca', 5000, CONVERT(datetime, '20200410', 112), CONVERT(datetime, '20210302', 112))
SET @id_et2 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_jk, N'PIEK', N'Sprzedawca', 5000, CONVERT(datetime, '20210415', 112), CONVERT(datetime, '20220115', 112))
SET @id_et3 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_ad, N'PIEK', N'Piekarza', 3500, CONVERT(datetime, '20220203', 112), NULL)
SET @id_et4 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_ad, N'SPACZ', N'Pączkarz',4000, CONVERT(datetime, '20210203', 112), NULL)
SET @id_et5 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_bk, N'SPACZ', N'Kasjer', 1500, CONVERT(datetime, '20211103', 112), NULL)
SET @id_et6 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_bk, N'DON', N'Kasjer', 1500, CONVERT(datetime, '20220116', 112), NULL)
SET @id_et7 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_mk, N'DON', N'Kasjer', 1500, CONVERT(datetime, '20210116', 112) , NULL)
SET @id_et8 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_mk, N'MPACZ', N'Kasjer', 1500, CONVERT(datetime, '20210521', 112) , NULL)
SET @id_et9 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_an, N'NPACZ', N'Ksiegowa', 6000, CONVERT(datetime, '20210629', 112) , NULL)
SET @id_et10= SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_jp, N'KAW', N'Barista', 4000 , CONVERT(datetime, '20210712', 112) , NULL)
SET @id_et11= SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_kn, N'SKL', N'Kasjer', 3500, CONVERT(datetime, '20190515', 112) ,NULL)
SET @id_et12= SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_ap, N'SKL2', N'Kasjer', 2000, CONVERT(datetime, '20181111', 112) ,NULL)
SET @id_et13 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_kp, N'FIR', N'Prezes', 30000, CONVERT(datetime, '20180216', 112) , NULL)
SET @id_et14 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_ko, N'FIR', N'Dostawca', 7000 , CONVERT(datetime, '20171206', 112) , NULL)
SET @id_et15 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_zp, N'FIR', N'Ksiegowa', 6000 , CONVERT(datetime, '20190924', 112) , NULL)
SET @id_et16 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_aj, N'FIR', N'Sprzedawca', 3000 , CONVERT(datetime, '20200817', 112) , NULL)
SET @id_et17 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_fj, N'PACZ', N'Ksiegowy', 6500 , CONVERT(datetime, '20170720', 112) , NULL)
SET @id_et18 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_mp, N'PACZ', N'Sprzedawca', 3000 , CONVERT(datetime, '20220123', 112) , NULL)
SET @id_et19 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_bp, N'PACZ', N'Logistyk', 5500 , CONVERT(datetime, '20200424', 112) , NULL)
SET @id_et20 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_jk, N'SPACZ', N'Sprzedawca', 4000 , CONVERT(datetime, '20220313', 112) , NULL)
SET @id_et21 = SCOPE_IDENTITY()
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_jk, N'DON', N'Pączkarza', 3200 , CONVERT(datetime, '20170425', 112) , NULL)
SET @id_et22 = SCOPE_IDENTITY()

/*

select * from MIASTA
/*id_miasta   nazwa                                              kod_woj
----------- -------------------------------------------------- -------
1           Warszawa                                           MAZ 
2			Grodzisk										   MAZ 
3			Krasnystaw										   LUBE
4			Opole											   OPL 
5			Suwałki											   OPL 
6			Gdynia											   POM 
7			Koniec											   ZPOM
8			Szczecin										   ZPOM
9			Koszalin										   ZPOM

(1 row(s) affected) 
*/

select * from OSOBY
/*
id_osoby	id_miasta	imie		nazwisko
-------		---------	--------	-----------
1			2			Jacek		Korytkowski
2			2			Adam		Kowalski
3			2			Beata		Kowalska
4			3			Michał		Nowak
5			3			Ania		Nowak
6			4			Julka		Piskorska
7			4			Krysia		Nowacka
8			5			Andrzej		Piatkowski
9			5			Karolina	Pawłowicz
10			6			Karol		Okoński
11			6			Zuzanna		Piskorska
12			7			Artur		Janczewski
13			7			Filip		Jagiełło
14			8			Marcin		Pietruk
15			8			Beata		Pietrk
16			9			Artur		Kapuściński
*/

select * from WOJ
/*
kod_woj		nazwa
--------	-----------
LUBE		LUBELSKIE
MAZ 		MAZOWIECKIE
OPL		 	OPOLSKIE
POD 		PODLASKIE
POM 		POMORSKIE
WLKP		WIELKOPOLSKIE
ZPOM		ZACHODNIOPOMORSKIE
*/

select * from FIRMY
/*
nazwa_skr	id_miasta	nazwa				kod_pocztowy	ulica
---------	---------	-----------------	-------------	-----------
DON  		3			Donuty				03-778			Truskawkowa
FIR  		7			Firma				45-113			Firmowa
FIR2 		8			Firma 2				55-890			Firmna
KAW  		6			Kawiarnia			76-890			Cukrowa
MPACZ		4			Mini Pączki			98-234			Lukrowa
NFIRM		8			Najlepsza Firma		43-908			Fir
NPACZ		5			Najlepsze Pączki	76-545			Berylowa
PACZ 		1			Pączkarnia			02-456			Chmielna 10
PIE  		1			Pierogarnia			02-422			Nowa
PIE2 		9			Piekrania 2			33-489			Piekarnicza
PIEK 		1			Piekarnia			03-121			Wesoła
SKL  		6			Sklep				23-456			Sklepowa
SKL2 		7			Sklep 2				45-112			Sklepna
SPACZ		2			Stara Pączkarnia	01-003			Tłusta
*/

select * from ETATY

/*
id_osoby	id_firmy	stanowisko		pensja		od			do			id_etatu
----------	---------	----------		-------		----------	----------	---------
1			PACZ 		Sprzedawca		5000.00		2019-03-02	2020-03-02	1
1			PIE  		Sprzedawca		5000.00		2020-04-10	2021-03-02	2
1			PIEK 		Sprzedawca		5000.00		2021-04-15	2022-01-15	3
2			PIEK 		Piekarz			3500.00		2022-02-03	NULL		4
2			SPACZ		Pączkarz		4000.00		2021-02-03	NULL		5
3			SPACZ		Kasjer			1500.00		2021-11-03	NULL		6
3			DON  		Kasjer			1500.00		2022-01-16	NULL		7
4			DON  		Kasjer			1500.00		2021-01-16	NULL		8
4			MPACZ		Kasjer			1500.00		2021-05-21	NULL		9
5			NPACZ		Ksiegowa		6000.00		2021-06-29	NULL		10
6			KAW  		Barista			4000.00		2021-07-12	NULL		11
7			SKL  		Kasjer			3500.00		2019-05-15	NULL		12
8			SKL2 		Kasjer			2000.00		2018-11-11	NULL		13
9			FIR  		Prezes			30000.00	2018-02-16	NULL		14
10			FIR  		Dostawca		7000.00		2017-12-06	NULL		15
11			FIR  		Ksiegowa		6000.00		2019-09-24	NULL		16
12			FIR  		Sprzedawca		3000.00		2020-08-17	NULL		17
13			PACZ 		Ksiegowy		6500.00		2017-07-20	NULL		18
14			PACZ 		Sprzedawca		3000.00		2022-01-23	NULL		19
15			PACZ 		Logistyk		5500.00		2020-04-24	NULL		20
1			SPACZ		Sprzedawca		4000.00		2022-03-13	NULL		21
2			DON  		Pączkarz		3200.00		2017-04-25	NULL		22
*/

/*
-Nie da sie wstawic osoby ktora nie istnieje

DECLARE @id_et23 int
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_aa, N'DON', N'Pączkarz', 3200 , CONVERT(datetime, '20170425', 112) , NULL)
SET @id_et23 = SCOPE_IDENTITY()

Msg 137, Level 15, State 2, Line 306
Must declare the scalar variable "@id_aa".
*/


/*
-Nie moazna usunac miasta w ktorym sa osoby/firmy

DELETE FROM MIASTA WHERE id_miasta = @id_gro

Msg 547, Level 16, State 0, Line 316
The DELETE statement conflicted with the REFERENCE constraint "FK_OSOBY_MIASTA". The conflict occurred in database "b_319031", table "dbo.OSOBY", column 'id_miasta'.
The statement has been terminated.
*/



/*
-Nie mozna usunac tabeli osoby jesli jest tabela etaty

DROP TABLE OSOBY

Msg 3726, Level 16, State 1, Line 327
Could not drop object 'OSOBY' because it is referenced by a FOREIGN KEY constraint.
*/

*/