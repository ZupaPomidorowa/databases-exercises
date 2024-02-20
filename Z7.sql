/*Z7*/
/* Projekt na 3 zajęcia */
/* stworzyć udostępnianie rowerów (uproszczoną)
**
** Tabela Rower (model, id_roweru, stan_pocz, stan_dostepny - dom stan_pocz)
** np. ('wigry3', 1, 35, 35) nalezy stworzyć trigger na INSERT ROWER, który przepisze
** stan_pocz do stan_dostepny - czyli kupilismy 35 sztu danej puli rowerów i tyle na
** wstepie jest dostępnych
** Skorzystać z tabeli OSOBY którą macie
** Tabela WYP (id_osoby, id_roweru, data, id_wyp PK)
** Tabela ZWR (id_osoby, id_roweru, data, id_zwr PK (int not null IDENTITY))
** Napisać triggery aby:
** dodanie rekordow do WYP powodowalo aktualizację Rower (stan_dostepny)
** UWAGA zakladamy ze na raz mozna dodawac wiele rekordow
** w tym dla tej samej osoby, z tym samym id_roweru

CREATE TABLE #wyp(id_os int not null, id_roweru int not null)
INSERT INTO #wyp (id_os, id_roweru, liczba) VALUES (1, 1), (1, 1), (2, 5)

Zwrot zwiększa stan_dostepny
** UWAGA !!! Zrealizować TRIGERY na kasowanie z WYP lub ZWR
** Zrealizować TRIGGERY, ze nastapiła pomyłka czyli UPDATE na WYP lub ZWR
** Wydaje mi sie, ze mozna napisac po jednym triggerze na WYP lub ZWR na
** wszystkie akcje INSERT / UPDATE / DELETE
**
** Testowanie: stworzcie procedurę, która pokaze wszystkie rowery,
** model, stan_pocz, stan_dost + SUM(liczba) z ZWR - SUM(liczba) z WYP =>
** ISNULL(SUM(Liczba),0) te dwie kolumny powiny być równe
** po wielu dzialaniach w bazie
** dzialania typu kasowanie rejestrowac w tabeli skasowane
** (rodzaj (wyp/zwr), id_os, id_roweru)
** osobne triggery na DELETE z WYP i ZWR które będą rejestrować skasowania
** opisać pełną historie wyp i zwr (łaczniem z kasowaniem) i ze po wszystkim stan OK
*/

/*tabele*/
CREATE TABLE dbo.ROWER
(
	model	nvarchar(50) NOT NULL,
	id_roweru	int NOT NULL IDENTITY CONSTRAINT PK_ROWER PRIMARY KEY,
	stan_poczatkowy int NOT NULL,
	stan_dostepny	int NULL
)
GO

CREATE TABLE dbo.WYP
(
	id_osoby int NOT NULL CONSTRAINT FK_WYP_OSOBY FOREIGN KEY REFERENCES OSOBY(id_osoby) ,
	id_roweru  int NOT NULL CONSTRAINT FK_WYP_ROWER FOREIGN KEY REFERENCES ROWER(id_roweru) ,
	data date NOT NULL ,
	id_wyp int NOT NULL IDENTITY CONSTRAINT PK_WYP PRIMARY KEY
)
GO

CREATE TABLE dbo.ZWR
(
	id_osoby int NOT NULL CONSTRAINT FK_ZWR_OSOBY FOREIGN KEY REFERENCES OSOBY(id_osoby) ,
	id_roweru  int NOT NULL CONSTRAINT FK_ZWR_ROWER FOREIGN KEY REFERENCES ROWER(id_roweru) ,
	data date NOT NULL ,
	id_zwr int NOT NULL IDENTITY CONSTRAINT PK_ZWR PRIMARY KEY
)
GO



/*trigger rower*/
ALTER TRIGGER tr_rower
ON ROWER
FOR INSERT
AS
	UPDATE ROWER SET stan_dostepny = stan_poczatkowy
GO

INSERT INTO ROWER (model, stan_poczatkowy) VALUES (N'wigry3', 35)
INSERT INTO ROWER (model, stan_poczatkowy) VALUES (N'wigry1', 25)
INSERT INTO ROWER (model, stan_poczatkowy) VALUES (N'scott', 5)
INSERT INTO ROWER (model, stan_poczatkowy) VALUES (N'giant', 30)
INSERT INTO ROWER (model, stan_poczatkowy) VALUES (N'trekking', 15)
INSERT INTO ROWER (model, stan_poczatkowy) VALUES (N'trekking2', 0)

/*
SELECT * FROM ROWER
model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				35
wigry1		2			25				25
scott		3			5				5
giant		4			30				30
trekking	5			15				15
trekking2	6			0				0
*/


/*trigger wypozyczenia*/
ALTER TRIGGER tr_wyp1
ON WYP
FOR INSERT
AS
		IF EXISTS (SELECT * FROM ROWER, WYP WHERE WYP.id_roweru = ROWER.id_roweru AND ROWER.stan_dostepny <= 0) 
			BEGIN
			RAISERROR(N'Brak roweru', 16, 1)
			ROLLBACK TRANSACTION
			END

		ELSE
		BEGIN
			UPDATE ROWER SET ROWER.stan_dostepny -= (SELECT COUNT(*) FROM inserted WHERE WYP.id_roweru = inserted.id_roweru AND ROWER.stan_dostepny>0)
			FROM ROWER
			JOIN WYP ON WYP.id_roweru = ROWER.id_roweru
		END		
GO

ALTER TRIGGER tr_wyp2
ON WYP
FOR DELETE, UPDATE
AS
			UPDATE ROWER SET ROWER.stan_dostepny -= (SELECT COUNT(*) FROM inserted WHERE WYP.id_roweru = inserted.id_roweru /*AND ROWER.stan_dostepny>0*/)
			FROM ROWER
			JOIN WYP ON WYP.id_roweru = ROWER.id_roweru

			UPDATE ROWER SET ROWER.stan_dostepny += (SELECT COUNT(*) FROM deleted WHERE ROWER.id_roweru = deleted.id_roweru)
GO

INSERT INTO WYP (id_osoby, id_roweru, data) VALUES (1, 1, CONVERT(datetime, '20211103', 112))
/* 
SELECT * FROM ROWER WHERE id_roweru = 1

model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				34
*/

INSERT INTO WYP (id_osoby, id_roweru, data) VALUES (1, 6, CONVERT(datetime, '20211103', 112))
/*
SPRAWDZENIE	PRZYPADKU WYPOZYCZENIA ROWERU KTOREGO NIE MA
SELECT * FROM ROWER WHERE id_roweru = 6

model		id_roweru	stan_poczatkowy	stan_dostepny
trekking2	6			0				0

Msg 50000, Level 16, State 1, Procedure tr_wyp1, Line 7 [Batch Start Line 136]
Brak roweru
Msg 3609, Level 16, State 1, Line 137
The transaction ended in the trigger. The batch has been aborted.
*/

INSERT INTO WYP (id_osoby, id_roweru, data) VALUES (2, 2, CONVERT(datetime, '20211103', 112)), 
(2, 2, CONVERT(datetime, '20211104', 112)), (2, 3, CONVERT(datetime, '20211104', 112))
/*
SELECT * FROM ROWER WHERE id_roweru = 2 OR id_roweru = 3

model		id_roweru	stan_poczatkowy		stan_dostepny
wigry1		2			25					23
scott		3			5					4
*/

/*
ROWER
model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				34

WYP
id_osoby	id_roweru	data		id_wyp
1			1			2021-11-03	1
*/
DELETE FROM WYP WHERE id_wyp = 1
/*
SELECT * FROM ROWER WHERE id_roweru = 1

model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				35
*/

/* Przed poleceniem update
SELECT * FROM ROWER WHERE id_roweru=3 OR id_roweru=4

model		id_roweru	stan_poczatkowy	stan_dostepny
scott		3			5				4
giant		4			30				30

SELECT * FROM WYP

id_osoby	id_roweru	data		id_wyp
2			3			2021-11-04	4
*/
UPDATE WYP SET id_roweru = 4 WHERE id_wyp = 4
/* Po poleceniu update
SELECT * FROM ROWER WHERE id_roweru=3 OR id_roweru=4

model		id_roweru	stan_poczatkowy	stan_dostepny
scott		3			5				5
giant		4			30				29

SELECT * FROM WYP

id_osoby	id_roweru	data		id_wyp
2			4			2021-11-04	4
*/



/*trigger zwroty*/
ALTER TRIGGER tr_zwr
ON ZWR
FOR INSERT, DELETE, UPDATE
AS
		UPDATE ROWER SET ROWER.stan_dostepny += (SELECT COUNT(*) FROM inserted WHERE ZWR.id_roweru = inserted.id_roweru) 
		FROM ROWER
		JOIN ZWR ON ZWR.id_roweru = ROWER.id_roweru

		UPDATE ROWER SET ROWER.stan_dostepny -= (SELECT COUNT(*) FROM deleted WHERE ROWER.id_roweru = deleted.id_roweru AND ROWER.stan_dostepny > 0) 
		/*FROM ROWER
		JOIN ZWR ON ZWR.id_roweru = ROWER.id_roweru*/

GO

/*
ROWER
model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				34
*/
INSERT INTO ZWR (id_osoby, id_roweru, data) VALUES (1, 1, CONVERT(datetime, '20211105', 112))
/*
ROWER
model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				35
*/

/*
ZWR
id_osoby	id_roweru	data		id_zwr
1			1			2021-11-05	1
*/
DELETE FROM ZWR WHERE id_zwr = 1
/*
ROWER
model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				34
*/

/*
ROWER
model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				35
wigry1		2			25				23
scott		3			5				4
*/
INSERT INTO ZWR (id_osoby, id_roweru, data) VALUES (2, 3, CONVERT(datetime, '20211105', 112))
/*
ZWR
id_osoby	id_roweru	data		id_zwr
1			1			2021-11-05	1
2			3			2021-11-05	2

ROWER
model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				35
wigry1		2			25				23
scott		3			5				5
*/
UPDATE ZWR SET id_roweru = 2 WHERE id_zwr = 2

/*
ZWR
id_osoby	id_roweru	data		id_zwr
1			1			2021-11-05	1
2			2			2021-11-05	2

ROWER
model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				35
wigry1		2			25				24
scott		3			5				4
*/


/*procedura*/
ALTER PROC SZUKAJ 
AS
	SELECT r.model, r.stan_poczatkowy, (r.stan_dostepny - (select count (z.id_roweru) from ZWR z WHERE z.id_roweru = r.id_roweru) +
	(select count (w.id_roweru) from WYP w WHERE w.id_roweru = r.id_roweru)
	) AS dostepne
	FROM ROWER r;
GO

/*kasowanie*/
CREATE TABLE dbo.SKASOWANE
(
	rodzaj nvarchar(5) NOT NULL ,
	id_osoby int NOT NULL CONSTRAINT FK_OSOBY FOREIGN KEY REFERENCES OSOBY(id_osoby) ,
	id_roweru  int NOT NULL CONSTRAINT FK_ROWER FOREIGN KEY REFERENCES ROWER(id_roweru) ,
)


CREATE TRIGGER tr_skasowane_wyp
ON WYP
FOR DELETE
AS
	INSERT INTO SKASOWANE (rodzaj, id_roweru, id_osoby) VALUES (N'WYP', (SELECT id_roweru FROM deleted), (SELECT id_osoby FROM deleted))
GO

CREATE TRIGGER tr_skasowane_zwr
ON ZWR
FOR DELETE
AS
	INSERT INTO SKASOWANE (rodzaj, id_roweru, id_osoby) VALUES (N'ZWR', (SELECT id_roweru FROM deleted), (SELECT id_osoby FROM deleted))
GO

/*podjete dzialania*/
INSERT INTO WYP (id_osoby, id_roweru, data) VALUES (1, 1, CONVERT(datetime, '20211103', 112))
INSERT INTO WYP (id_osoby, id_roweru, data) VALUES (2, 2, CONVERT(datetime, '20211103', 112)), 
(2, 2, CONVERT(datetime, '20211104', 112)), (2, 3, CONVERT(datetime, '20211104', 112))
DELETE FROM WYP WHERE id_wyp = 1
UPDATE WYP SET id_roweru = 4 WHERE id_wyp = 4
INSERT INTO WYP (id_osoby, id_roweru, data) VALUES (1, 1, CONVERT(datetime, '20211103', 112))
INSERT INTO ZWR (id_osoby, id_roweru, data) VALUES (1, 1, CONVERT(datetime, '20211105', 112))
DELETE FROM ZWR WHERE id_zwr = 1
INSERT INTO ZWR (id_osoby, id_roweru, data) VALUES (2, 4, CONVERT(datetime, '20211105', 112))
UPDATE ZWR SET id_roweru = 2 WHERE id_zwr = 2
/*
SELECT * FROM ROWER

model		id_roweru	stan_poczatkowy	stan_dostepny
wigry3		1			35				34
wigry1		2			25				24
scott		3			5				5
giant		4			30				29
trekking	5			15				15
trekking2	6			0				0

SELECT * FROM WYP

id_osoby	id_roweru	data		id_wyp
2			2			2021-11-03	2
2			2			2021-11-04	3
2			4			2021-11-04	4
1			1			2021-11-03	5

SELECT * FROM ZWR

id_osoby	id_roweru	data		id_zwr
2			2			2021-11-05	2
*/

/*Uruchamiamy procedure szukaj*/
SZUKAJ
/*
model		stan_poczatkowy	dostepne
wigry3		35				35
wigry1		25				25
scott		5				5
giant		30				30
trekking	15				15
trekking2	0				0

Stan poczatkowy zgadza sie ze stanem dostepne
*/

SELECT * FROM SKASOWANE
/*
rodzaj	id_osoby	id_roweru
WYP		1			1
ZWR		1			1

Usuniete wypozyczenia/zwroty zgadzaja sie
*/

/*Po wszystkich dzianiach w bazie, wszystko sie zgadza*/




