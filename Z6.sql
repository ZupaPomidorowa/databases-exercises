/*Z5 
Z1: Napisać trigger, który będzie zamieniał spacje (na _) z pola NAZWA_SKR w tabeli FIRMY
Trigger na INSERT, UPDATE
UWAGA !! Trigger będzie robił UPDATE na polu NAZWA_SKR
To grozi REKURENCJĄ i przepelnieniem stosu
Dlatego trzeba będzie sprawdzać UPDATE(NAZWA_SKR) i sprawdzać czy we 
 wstawionych rekordach były spacje i tylko takowe poprawiać (ze spacjami w NAZWA_SKR)

Z2: Napisać procedurę szukającą WOJ z paramertrami
@nazwa_wzor nvarchar(20) = NULL
@kod_woj_wzor nvarchar(20) = NULL
@pokaz_zarobki bit = 0
Procedura ma mieć zmienną @sql nvarchar(1000), którą buduje dynamicznie
@pokaz_zarobki = 0 => (WOJ.NAZWA AS woj, kod_woj)
@pokaz_zarobki = 1 => (WOJ.NAZWA AS woj, kod_woj
	, śr_z_akt_etatow)
Mozliwe wywołania: EXEC sz_w @nazw_wzor = N'M%'
powinno zbudować zmienną tekstową 
@sql = N'SELECT w.* FROM woj w WHERE w.nazwa LIKE NM% '
uruchomienie zapytania to EXEC sp_sqlExec @sql
rekomenduję aby najpierw procedura zwracała zapytanie SELECT @sql
a dopiero jak będą poprawne uruachamiała je
*/

/*Z1*/
CREATE TRIGGER tr_firmy
ON FIRMY
FOR INSERT, UPDATE
AS
	IF UPDATE(nazwa_skr) AND EXISTS (SELECT 1 FROM inserted i where i.nazwa_skr like N'% %' )
		UPDATE FIRMY SET nazwa_skr = REPLACE (nazwa_skr, N' ', N'_') 
		WHERE nazwa_skr IN  (select i.nazwa_skr from inserted i where i.nazwa_skr like N'% %' )
GO

INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'N AAA', 9, N'Naaajlepsze Pączki', N'76-545', N'Berylowa')


UPDATE FIRMY SET nazwa_skr = N'N AJL'  where nazwa_skr like N'N AAA'

/*
nazwa_skr	id_miasta	nazwa				kod_pocztowy	ulica
N AAA		9			Naaajlepsze Pączki	76-545			Berylowa
	
N_AJL		9			Naaajlepsze Pączki	76-545			Berylowa
*/

/*Z2*/
CREATE PROCEDURE szukaj AS

ALTER PROC szukaj (
	@nazwa_wzor nvarchar(20) = NULL,
	@kod_woj_wzor nvarchar(20) = NULL,
	@pokaz_zarobki bit = 0)
AS
DECLARE @sql nvarchar(1000)

IF @pokaz_zarobki=1
		BEGIN
			set @sql = 'SELECT w.nazwa AS wojewodztwo, AVG(e.pensja) AS srednia_pensja'
			set @sql = @sql + ' FROM WOJ w'
			set @sql = @sql + ' JOIN MIASTA m ON m.kod_woj = w.kod_woj and w.nazwa like ' + N'''' + @nazwa_wzor + N''''
			set @sql = @sql + ' JOIN FIRMY f ON m.id_miasta = f.id_miasta '
			set @sql = @sql + ' JOIN (SELECT et.id_firmy, et.pensja FROM ETATY et WHERE et.do IS NULL) e ON f.nazwa_skr = e.id_firmy'
			set @sql = @sql + ' GROUP BY w.nazwa'
			set @sql = @sql + ' UNION ALL'
			set @sql = @sql + ' SELECT w.nazwa, '
			set @sql = @sql + ' ISNULL( CONVERT (money, null), 0) '
			set @sql = @sql + ' FROM WOJ w'
			set @sql = @sql + ' WHERE w.nazwa like ' +N'''' + @nazwa_wzor + N'''' + ' and NOT EXISTS '
			set @sql = @sql + ' (SELECT 1'
			set @sql = @sql + ' FROM MIASTA m, FIRMY f, ETATY e'
			set @sql = @sql + ' WHERE m.kod_woj = w.kod_woj AND'
			set @sql = @sql + ' 	m.id_miasta = f.id_miasta AND'
			set @sql = @sql + ' 	f.nazwa_skr = e.id_firmy AND '
			set @sql = @sql + '		e.do IS NULL)'
		END
	ELSE
		set @sql = 'select kod_woj, nazwa from WOJ where nazwa='+ N'''' + @nazwa_wzor + N''''
select @sql
EXEC sp_sqlexec @sql



EXEC szukaj @nazwa_wzor='M%', @pokaz_zarobki=1

/*
wojewodztwo		srednia_pensja
MAZOWIECKIE		4000.00
*/