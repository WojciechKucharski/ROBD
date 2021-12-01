DROP TABLE c##robd.klient;
DROP TABLE c##robd.rodzaj_przedmiotu;
DROP DATABASE LINK DB_LINK;

CREATE DATABASE LINK DB_LINK CONNECT TO c##robd IDENTIFIED BY "123" USING '192.168.56.1/XE';
set serveroutput on size 30000;
SET SERVEROUTPUT ON;


----------- TABELE ------------
CREATE TABLE c##robd.rodzaj_przedmiotu(
    id_rodzaj_przedmiotu int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    typ VARCHAR2(30) NOT NULL,
    opis VARCHAR2(50) NOT NULL--,
    --CONSTRAINTS pk_rodzaj_przedmiotu PRIMARY KEY (id_rodzaj_przedmiotu)
);

CREATE TABLE c##robd.klient(
    id_klient int NOT NULL,
    pesel VARCHAR2(11) NOT NULL--,
    --CONSTRAINTS pk_klient PRIMARY KEY (id_klient)
);


---------- REPLIKACJA ----------- RODZAJ PRZEDMIOTU - WSZYSTKIE
DROP MATERIALIZED VIEW c##robd.rodzaj_przedmiotu_r;
CREATE MATERIALIZED VIEW c##robd.rodzaj_przedmiotu_r
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT * FROM c##robd.rodzaj_przedmiotu_r@DB_LINK;


---------- REPLIKACJA ----------- KLIENT - WSZYSCY
DROP MATERIALIZED VIEW c##robd.klient_r;
CREATE MATERIALIZED VIEW c##robd.klient_r
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT * FROM c##robd.klient_r@DB_LINK;


---------- REPLIKACJA ----------- WYPOZYCZALNIA
DROP MATERIALIZED VIEW c##robd.wypozyczalnia;
CREATE MATERIALIZED VIEW c##robd.wypozyczalnia
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT * FROM c##robd.wypozyczalnia@DB_LINK;


---------- REPLIKACJA ----------- PRZEDMIOT
DROP MATERIALIZED VIEW c##robd.przedmiot;
CREATE MATERIALIZED VIEW c##robd.przedmiot
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT * FROM c##robd.przedmiot@DB_LINK;


---------- REPLIKACJA ----------- WYPOZYCZENIE
DROP MATERIALIZED VIEW c##robd.wypozyczenie;
CREATE MATERIALIZED VIEW c##robd.wypozyczenie
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT * FROM c##robd.wypozyczenie@DB_LINK;


---------- REPLIKACJA ----------- DOSTĘPNE
DROP MATERIALIZED VIEW c##robd.dostepne_przedmioty;
CREATE MATERIALIZED VIEW c##robd.dostepne_przedmioty
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT * FROM c##robd.dostepne_przedmioty@DB_LINK;


---------- REPLIKACJA ----------- NIEDOSTĘPNE
DROP MATERIALIZED VIEW c##robd.niedostepne_przedmioty;
CREATE MATERIALIZED VIEW c##robd.niedostepne_przedmioty
build DEFERRED
refresh force
START WITH SYSDATE+(1/(24*60*60))
NEXT SYSDATE+(1/(24*60*30))
AS
SELECT * FROM c##robd.niedostepne_przedmioty@DB_LINK;


---------- SYNONYMS -----------
DROP SYNONYM c##robd.dodaj_rodzaj_przedmiotu;
CREATE SYNONYM c##robd.dodaj_rodzaj_przedmiotu
FOR c##robd.dodaj_rodzaj_przedmiotu@DB_LINK;


DROP SYNONYM c##robd.dodaj_klienta;
CREATE SYNONYM c##robd.dodaj_klienta
FOR c##robd.dodaj_klienta@DB_LINK;


DROP SYNONYM c##robd.dodaj_wypozyczalnie;
CREATE SYNONYM c##robd.dodaj_wypozyczalnie
FOR c##robd.dodaj_wypozyczalnie@DB_LINK;


DROP SYNONYM c##robd.dodaj_przedmiot;
CREATE SYNONYM c##robd.dodaj_przedmiot
FOR c##robd.dodaj_przedmiot@DB_LINK;


DROP SYNONYM c##robd.wypozycz_przedmiot;
CREATE SYNONYM c##robd.wypozycz_przedmiot
FOR c##robd.wypozycz_przedmiot@DB_LINK;


DROP SYNONYM c##robd.oddodaj_przedmiot;
CREATE SYNONYM c##robd.oddodaj_przedmiot
FOR c##robd.oddodaj_przedmiot@DB_LINK;


DROP VIEW c##robd.aktywne_wypozyczenia;
CREATE VIEW c##robd.aktywne_wypozyczenia
AS
SELECT * FROM c##robd.wypozyczenie WHERE CURRENT_TIMESTAMP between data_wypozyczenia AND data_oddania