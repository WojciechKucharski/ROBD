----------- SETTINGS ------------
set serveroutput on size 30000;
SET SERVEROUTPUT ON;
----------- DBLINK ------------
DROP DATABASE LINK DB_LINK;
CREATE DATABASE LINK DB_LINK CONNECT TO c##robd IDENTIFIED BY "123" USING '192.168.56.102/XE';
----------- TABLES ------------
----------- R.P. ------------
DROP TABLE c##robd.rodzaj_przedmiotu;
CREATE TABLE c##robd.rodzaj_przedmiotu(
    id_rodzaj_przedmiotu int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    typ VARCHAR2(30) NOT NULL,
    opis VARCHAR2(50) NOT NULL--,
    --CONSTRAINTS pk_rodzaj_przedmiotu PRIMARY KEY (id_rodzaj_przedmiotu)
);

DROP SEQUENCE c##robd.rodzaj_przedmiotu_seq;
CREATE SEQUENCE c##robd.rodzaj_przedmiotu_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

----------- KLIENT ------------
DROP TABLE c##robd.klient;
CREATE TABLE c##robd.klient(
    id_klient int NOT NULL,
    imie VARCHAR2(25) NOT NULL,
    nazwisko VARCHAR2(25) NOT NULL,
    nr_telefonu Number(9) NOT NULL,
    email VARCHAR2(30) NOT NULL--,
    --CONSTRAINTS pk_klient PRIMARY KEY (id_klient)
);

DROP SEQUENCE c##robd.klient_seq;
CREATE SEQUENCE c##robd.klient_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

----------- WYPOZYCZALNIA ------------
DROP TABLE c##robd.wypozyczalnia;
CREATE TABLE c##robd.wypozyczalnia(
    id_wypozyczalnia int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    adres VARCHAR2(30) NOT NULL--,
    --CONSTRAINTS pk_wypozyczalnia PRIMARY KEY (id_wypozyczalnia)
);

DROP SEQUENCE c##robd.wypozyczalnia_seq;
CREATE SEQUENCE c##robd.wypozyczalnia_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

----------- PRZEDMIOT ------------
DROP TABLE c##robd.przedmiot;
CREATE TABLE c##robd.przedmiot(
    id_przedmiot int NOT NULL,
    id_wypozyczalnia int NOT NULL,
    id_rodzaj_przedmiotu int NOT NULL,
    nazwa_przedmiotu VARCHAR2(25) NOT NULL--,
    --CONSTRAINTS fk_wypozyczalnia FOREIGN KEY (id_wypozyczalnia) REFERENCES c##robd.wypozyczalnia (id_wypozyczalnia),
    --CONSTRAINTS fk_rodzaj_przedmiotu FOREIGN KEY (id_rodzaj_przedmiotu) REFERENCES c##robd.rodzaj_przedmiotu (id_rodzaj_przedmiotu),
    --CONSTRAINTS pk_przedmiot PRIMARY KEY (id_przedmiot)
);

DROP SEQUENCE c##robd.przedmiot_seq;
CREATE SEQUENCE c##robd.przedmiot_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

----------- WYPOZYCZENIE ------------
DROP TABLE c##robd.wypozyczenie;
CREATE TABLE c##robd.wypozyczenie(
    id_wypozyczenie int NOT NULL,
    id_przedmiot int NOT NULL,
    id_klient int NOT NULL,
    data_wypozyczenia TIMESTAMP,
    data_oddania TIMESTAMP--,
    --CONSTRAINTS fk_przedmiot FOREIGN KEY (id_przedmiot) REFERENCES c##robd.przedmiot (id_przedmiot),
    --CONSTRAINTS fk_klient FOREIGN KEY (id_klient) REFERENCES c##robd.klient (id_klient),
    --CONSTRAINTS pk_wypozyczenie PRIMARY KEY (id_wypozyczenie)
);

DROP SEQUENCE c##robd.wypozyczenie_seq;
CREATE SEQUENCE c##robd.wypozyczenie_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;


---------- FRAGMENTACJA POZIOMA R.P. -----------
CREATE OR REPLACE PROCEDURE c##robd.dodaj_rodzaj_przedmiotu
(
    nazwa_ IN VARCHAR2,
    typ_ IN VARCHAR2,
    opis_ IN VARCHAR2
)
AS
	id int;
BEGIN
	id := c##robd.rodzaj_przedmiotu_seq.NEXTVAL;
	IF typ_ = 'konsola' THEN
		INSERT INTO c##robd.rodzaj_przedmiotu@DB_LINK(id_rodzaj_przedmiotu, nazwa, typ, opis)
		VALUES (id, nazwa_, typ_, opis_);
	ELSE
		INSERT INTO c##robd.rodzaj_przedmiotu(id_rodzaj_przedmiotu, nazwa, typ, opis)
		VALUES (id, nazwa_, typ_, opis_);
	END IF;
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/

---------- FRAGMENTACJA PIONOWA KLIENT -----------
CREATE OR REPLACE PROCEDURE c##robd.dodaj_klienta
(
	imie_ IN VARCHAR2,
    nazwisko_ IN VARCHAR2,
    nr_telefonu_ IN Number,
    email_ IN VARCHAR2,
	pesel_ in VARCHAR2
)
AS
    id int;
BEGIN
    id := c##robd.klient_seq.NEXTVAL;
    INSERT INTO c##robd.klient(id_klient, imie, nazwisko, nr_telefonu, email)
    VALUES (id, imie_, nazwisko_, nr_telefonu_, email_);
    INSERT INTO c##robd.klient@DB_LINK(id_klient, pesel)
    VALUES (id, pesel_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/

---------- WIDOKI -----------

DROP SYNONYM c##robd.klient_f;
DROP MATERIALIZED VIEW c##robd.rodzaj_przedmiotu_r;
DROP MATERIALIZED VIEW c##robd.klient_r;


CREATE SYNONYM c##robd.klient_f
FOR c##robd.klient@DB_LINK;


CREATE MATERIALIZED VIEW c##robd.klient_r
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT c##robd.klient.*,c##robd.klient_f.pesel FROM c##robd.klient_f FULL JOIN c##robd.klient ON c##robd.klient.id_klient = c##robd.klient_f.id_klient;


CREATE MATERIALIZED VIEW c##robd.rodzaj_przedmiotu_r
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT * FROM c##robd.rodzaj_przedmiotu
UNION
SELECT * FROM c##robd.rodzaj_przedmiotu@DB_LINK;


---------- FUNKCJONALNOŚCI ŁATWE -----------

CREATE OR REPLACE PROCEDURE c##robd.dodaj_wypozyczalnie
(
    nazwa_ IN VARCHAR2,
    adres_ IN VARCHAR2
)
AS
BEGIN
    INSERT INTO c##robd.wypozyczalnia(id_wypozyczalnia, nazwa, adres)
    VALUES (c##robd.wypozyczalnia_seq.NEXTVAL, nazwa_, adres_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/

--######################################################################################
-- FUNKCJONALNOŚCI TRUDNE

CREATE OR REPLACE PROCEDURE c##robd.dodaj_przedmiot
(
    nazwa_przedmiotu_ IN VARCHAR2,
	id_wypozyczalnia_ IN int,
    id_rodzaj_przedmiotu_ IN int
	
)
AS
BEGIN
    INSERT INTO c##robd.przedmiot(id_przedmiot, id_wypozyczalnia, id_rodzaj_przedmiotu, nazwa_przedmiotu)
    VALUES (c##robd.przedmiot_seq.NEXTVAL, id_wypozyczalnia_, id_rodzaj_przedmiotu_, nazwa_przedmiotu_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/

--######################################################################################


CREATE OR REPLACE PROCEDURE c##robd.wypozycz_przedmiot
(
	id_przedmiot_ IN int,
    id_klient_ IN int
)
AS
    liczba int;
BEGIN
    SELECT count(*) INTO liczba FROM c##robd.przedmiot 
    WHERE id_przedmiot NOT IN (
        SELECT DISTINCT id_przedmiot
        FROM c##robd.wypozyczenie
        WHERE CURRENT_TIMESTAMP between data_wypozyczenia AND data_oddania
    ) AND id_przedmiot = id_przedmiot_;
    IF liczba >= 1 THEN
        INSERT INTO c##robd.wypozyczenie(id_wypozyczenie, id_przedmiot, id_klient, data_wypozyczenia, data_oddania)
        VALUES (c##robd.wypozyczenie_seq.NEXTVAL, id_przedmiot_, id_klient_, CURRENT_TIMESTAMP, TO_DATE('2044-DEC-25 17:30','YYYY-MON-DD HH24:MI','NLS_DATE_LANGUAGE=AMERICAN'));
        commit;
    END IF;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/
--######################################################################################

CREATE OR REPLACE PROCEDURE c##robd.oddaj_przedmiot
(
    id_wypozyczenie_ IN int
)
AS
BEGIN
    UPDATE c##robd.wypozyczenie
    SET data_oddania = CURRENT_TIMESTAMP
    WHERE id_wypozyczenie = id_wypozyczenie_;
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/

--######################################################################################

--- TURBO VIEW ---
DROP VIEW c##robd.dostepne_przedmioty;
CREATE VIEW c##robd.dostepne_przedmioty
AS
SELECT * FROM c##robd.przedmiot 
WHERE id_przedmiot NOT IN (
    SELECT DISTINCT id_przedmiot
    FROM c##robd.wypozyczenie
    WHERE CURRENT_TIMESTAMP between data_wypozyczenia AND data_oddania
);


DROP VIEW c##robd.niedostepne_przedmioty;
CREATE VIEW c##robd.niedostepne_przedmioty
AS
SELECT * FROM c##robd.przedmiot 
WHERE id_przedmiot IN (
    SELECT DISTINCT id_przedmiot
    FROM c##robd.wypozyczenie
    WHERE CURRENT_TIMESTAMP between data_wypozyczenia AND data_oddania
);
--######################################################################################