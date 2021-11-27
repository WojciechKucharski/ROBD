DROP TABLE c##scottt.klient;
DROP TABLE c##scottt.wypozyczalnia;
DROP TABLE c##scottt.rodzaj_przedmiotu;

set serveroutput on size 30000;
SET SERVEROUTPUT ON;


----------- TABELE ------------

CREATE TABLE c##scottt.rodzaj_przedmiotu(
    id_rodzaj_przedmiotu int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    typ VARCHAR2(30) NOT NULL,
    opis VARCHAR2(50) NOT NULL,
    CONSTRAINTS pk_rodzaj_przedmiotu PRIMARY KEY (id_rodzaj_przedmiotu)
);

CREATE TABLE c##scottt.klient(
    id_klient int NOT NULL,
    pesel VARCHAR2(11) NOT NULL,
    CONSTRAINTS pk_klient PRIMARY KEY (id_klient)
);

CREATE TABLE c##scottt.wypozyczalnia(
    id_wypozyczalnia int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    adres VARCHAR2(30) NOT NULL,
    CONSTRAINTS pk_wypozyczalnia PRIMARY KEY (id_wypozyczalnia)
);
---------- FRAGMENTACJA POZIOMA R.P. -----------
DROP SYNONYM c##scottt.rodzaj_przedmiotu_r;
DROP SYNONYM c##scottt.dodaj_rodzaj_przedmiotu;

CREATE SYNONYM c##scottt.rodzaj_przedmiotu_r
FOR c##scott.rodzaj_przedmiotu_r@DATABASE_LINK2;

CREATE SYNONYM c##scottt.dodaj_rodzaj_przedmiotu
FOR c##scott.dodaj_rodzaj_przedmiotu@DATABASE_LINK2;

---------- FRAGMENTACJA POZIOMA KLIENT -----------
DROP SYNONYM c##scottt.klient_seq;

CREATE SYNONYM c##scottt.klient_seq
FOR c##scott.klient_seq@DATABASE_LINK2;

CREATE OR REPLACE PROCEDURE c##scottt.dodaj_klienta
(
	pesel_ in VARCHAR2
)
AS
BEGIN
	INSERT INTO c##scottt.klient(id_klient, pesel)
    VALUES (c##scottt.klient_seq.CURRVAL, pesel_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/