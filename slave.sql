DROP TABLE c##scottt.klient;
DROP TABLE c##scottt.rodzaj_przedmiotu;

set serveroutput on size 30000;
SET SERVEROUTPUT ON;


----------- TABELE ------------

CREATE TABLE c##scottt.rodzaj_przedmiotu(
    id_rodzaj_przedmiotu int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    typ VARCHAR2(30) NOT NULL,
    opis VARCHAR2(50) NOT NULL--,
    --CONSTRAINTS pk_rodzaj_przedmiotu PRIMARY KEY (id_rodzaj_przedmiotu)
);

CREATE TABLE c##scottt.klient(
    id_klient int NOT NULL,
    pesel VARCHAR2(11) NOT NULL--,
    --CONSTRAINTS pk_klient PRIMARY KEY (id_klient)
);

---------- FRAGMENTACJA POZIOMA R.P. -----------
DROP SYNONYM c##scottt.rodzaj_przedmiotu_r;
DROP SYNONYM c##scottt.dodaj_rodzaj_przedmiotu;

CREATE SYNONYM c##scottt.rodzaj_przedmiotu_r
FOR c##scott.rodzaj_przedmiotu_r@DATABASE_LINK2;

CREATE SYNONYM c##scottt.dodaj_rodzaj_przedmiotu
FOR c##scott.dodaj_rodzaj_przedmiotu@DATABASE_LINK2;

---------- FRAGMENTACJA POZIOMA KLIENT -----------
DROP SYNONYM c##scottt.klient_r;
DROP SYNONYM c##scottt.dodaj_klienta;

CREATE SYNONYM c##scottt.klient_r
FOR c##scott.klient_r@DATABASE_LINK2;

CREATE SYNONYM c##scottt.dodaj_klienta
FOR c##scott.dodaj_klienta@DATABASE_LINK2;

---------- REPLIKACJA -----------
DROP MATERIALIZED VIEW c##scottt.wypozyczalnia;

CREATE MATERIALIZED VIEW c##scottt.wypozyczalnia
build DEFERRED
refresh force
START WITH SYSDATE+(1/(2460))
NEXT SYSDATE+(1/(2430))
AS
SELECT * FROM c##scott.wypozyczalnia@DATABASE_LINK2;