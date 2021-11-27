DROP TABLE c##scott.wypozyczenie;
DROP TABLE c##scott.klient;
DROP TABLE c##scott.przedmiot;
DROP TABLE c##scott.wypozyczalnia;
DROP TABLE c##scott.rodzaj_przedmiotu;

set serveroutput on size 30000;
SET SERVEROUTPUT ON;
----------- TABELE ------------

CREATE TABLE c##scott.rodzaj_przedmiotu(
    id_rodzaj_przedmiotu int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    typ VARCHAR2(30) NOT NULL,
    opis VARCHAR2(50) NOT NULL,
    CONSTRAINTS pk_rodzaj_przedmiotu PRIMARY KEY (id_rodzaj_przedmiotu)
);

CREATE TABLE c##scott.klient(
    id_klient int NOT NULL,
    imie VARCHAR2(25) NOT NULL,
    nazwisko VARCHAR2(25) NOT NULL,
    nr_telefonu Number(9) NOT NULL,
    email VARCHAR2(30) NOT NULL,
    CONSTRAINTS pk_klient PRIMARY KEY (id_klient)
);

CREATE TABLE c##scott.wypozyczalnia(
    id_wypozyczalnia int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    adres VARCHAR2(30) NOT NULL,
    CONSTRAINTS pk_wypozyczalnia PRIMARY KEY (id_wypozyczalnia)
);

CREATE TABLE c##scott.przedmiot(
    id_przedmiot int NOT NULL,
    id_wypozyczalnia int NOT NULL,
    id_rodzaj_przedmiotu int NOT NULL,
    numer_seryjnt VARCHAR2(15) NOT NULL,
    CONSTRAINTS fk_wypozyczalnia FOREIGN KEY (id_wypozyczalnia) REFERENCES c##scott.wypozyczalnia (id_wypozyczalnia),
    CONSTRAINTS fk_rodzaj_przedmiotu FOREIGN KEY (id_rodzaj_przedmiotu) REFERENCES c##scott.rodzaj_przedmiotu (id_rodzaj_przedmiotu),
    CONSTRAINTS pk_przedmiot PRIMARY KEY (id_przedmiot)
);

CREATE TABLE c##scott.wypozyczenie(
    id_wypozyczenie int NOT NULL,
    id_przedmiot int NOT NULL,
    id_klient int NOT NULL,
    data_wypozyczenia DATE,
    data_oddania DATE,
    CONSTRAINTS fk_przedmiot FOREIGN KEY (id_przedmiot) REFERENCES c##scott.przedmiot (id_przedmiot),
    CONSTRAINTS fk_klient FOREIGN KEY (id_klient) REFERENCES c##scott.klient (id_klient),
    CONSTRAINTS pk_wypozyczenie PRIMARY KEY (id_wypozyczenie)
);
---------- FRAGMENTACJA POZIOMA R.P. -----------
DROP VIEW c##scott.rodzaj_przedmiotu_r;
DROP SEQUENCE c##scott.rodzaj_przedmiotu_seq;

CREATE SEQUENCE c##scott.rodzaj_przedmiotu_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE OR REPLACE VIEW c##scott.rodzaj_przedmiotu_r
AS
SELECT * FROM c##scott.rodzaj_przedmiotu
UNION
SELECT * FROM c##scottt.rodzaj_przedmiotu@DATABASE_LINK1;

CREATE OR REPLACE PROCEDURE c##scott.dodaj_rodzaj_przedmiotu
(
    nazwa_ IN VARCHAR2,
    typ_ IN VARCHAR2,
    opis_ IN VARCHAR2
)
AS
BEGIN
    INSERT INTO c##scott.rodzaj_przedmiotu(id_rodzaj_przedmiotu, nazwa, typ, opis)
    VALUES (c##scott.rodzaj_przedmiotu_seq.NEXTVAL, nazwa_, typ_, opis_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/
---------- FRAGMENTACJA PIONOWA KLIENT -----------
DROP VIEW c##scott.klient_r;
DROP SEQUENCE c##scott.klient_seq;
DROP SYNONYM c##scott.klient_f;
DROP SYNONYM c##scott.dodaj_klienta_pesel;

CREATE SYNONYM c##scott.dodaj_klienta_pesel
FOR c##scottt.dodaj_klienta@DATABASE_LINK1;

CREATE SYNONYM c##scott.klient_f
FOR c##scottt.klient@DATABASE_LINK1;

CREATE SEQUENCE c##scott.klient_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE VIEW c##scott.klient_r
AS
SELECT c##scott.klient.*,c##scott.klient_f.pesel FROM c##scott.klient_f FULL JOIN c##scott.klient ON c##scott.klient.id_klient = c##scott.klient_f.id_klient;


CREATE OR REPLACE PROCEDURE c##scott.dodaj_klienta
(
	imie_ IN VARCHAR2,
    nazwisko_ IN VARCHAR2,
    nr_telefonu_ IN Number,
    email_ IN VARCHAR2,
	pesel_ in VARCHAR2
)
AS
BEGIN
    INSERT INTO c##scott.klient(id_klient, imie, nazwisko, nr_telefonu, email)
    VALUES (c##scott.klient_seq.NEXTVAL, imie_, nazwisko_, nr_telefonu_, email_);
	c##scott.dodaj_klienta_pesel(pesel_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/