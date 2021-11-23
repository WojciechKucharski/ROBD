DROP TABLE c##scott.wypozyczenie;
DROP TABLE c##scott.klient;
DROP TABLE c##scott.przedmiot;
DROP TABLE c##scott.wypozyczalnia;
DROP TABLE c##scott.rodzaj_przedmiotu;

DROP SEQUENCE c##scott.wypozyczenie_seq;
DROP SEQUENCE c##scott.klient_seq;
DROP SEQUENCE c##scott.przedmiot_seq;
DROP SEQUENCE c##scott.wypozyczalnia_seq;
DROP SEQUENCE c##scott.rodzaj_przedmiotu_seq;


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
	pesel VARCHAR2(11) NOT NULL,
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

---------- SEKWENCJE -----------

CREATE SEQUENCE c##scott.rodzaj_przedmiotu_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE SEQUENCE c##scott.klient_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE SEQUENCE c##scott.wypozyczalnia_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE SEQUENCE c##scott.przedmiot_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE SEQUENCE c##scott.wypozyczenie_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

---------- FUNKCJE -----------
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



