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
    opis VARCHAR2(50) NOT NULL--,
    --CONSTRAINTS pk_rodzaj_przedmiotu PRIMARY KEY (id_rodzaj_przedmiotu)
);

CREATE TABLE c##scott.klient(
    id_klient int NOT NULL,
    imie VARCHAR2(25) NOT NULL,
    nazwisko VARCHAR2(25) NOT NULL,
    nr_telefonu Number(9) NOT NULL,
    email VARCHAR2(30) NOT NULL--,
    --CONSTRAINTS pk_klient PRIMARY KEY (id_klient)
);

CREATE TABLE c##scott.wypozyczalnia(
    id_wypozyczalnia int NOT NULL,
    nazwa VARCHAR2(30) NOT NULL,
    adres VARCHAR2(30) NOT NULL--,
    --CONSTRAINTS pk_wypozyczalnia PRIMARY KEY (id_wypozyczalnia)
);

CREATE TABLE c##scott.przedmiot(
    id_przedmiot int NOT NULL,
    id_wypozyczalnia int NOT NULL,
    id_rodzaj_przedmiotu int NOT NULL,
    numer_seryjny VARCHAR2(15) NOT NULL--,
    --CONSTRAINTS fk_wypozyczalnia FOREIGN KEY (id_wypozyczalnia) REFERENCES c##scott.wypozyczalnia (id_wypozyczalnia),
    --CONSTRAINTS fk_rodzaj_przedmiotu FOREIGN KEY (id_rodzaj_przedmiotu) REFERENCES c##scott.rodzaj_przedmiotu (id_rodzaj_przedmiotu),
    --CONSTRAINTS pk_przedmiot PRIMARY KEY (id_przedmiot)
);

CREATE TABLE c##scott.wypozyczenie(
    id_wypozyczenie int NOT NULL,
    id_przedmiot int NOT NULL,
    id_klient int NOT NULL,
    data_wypozyczenia TIMESTAMP,
    data_oddania TIMESTAMP--,
    --CONSTRAINTS fk_przedmiot FOREIGN KEY (id_przedmiot) REFERENCES c##scott.przedmiot (id_przedmiot),
    --CONSTRAINTS fk_klient FOREIGN KEY (id_klient) REFERENCES c##scott.klient (id_klient),
    --CONSTRAINTS pk_wypozyczenie PRIMARY KEY (id_wypozyczenie)
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
	id int;
BEGIN
	id := c##scott.rodzaj_przedmiotu_seq.NEXTVAL;
	IF typ_ = 'konsola' THEN
		INSERT INTO c##scottt.rodzaj_przedmiotu@DATABASE_LINK1(id_rodzaj_przedmiotu, nazwa, typ, opis)
		VALUES (id, nazwa_, typ_, opis_);
	ELSE
		INSERT INTO c##scott.rodzaj_przedmiotu(id_rodzaj_przedmiotu, nazwa, typ, opis)
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
DROP VIEW c##scott.klient_r;
DROP SEQUENCE c##scott.klient_seq;
DROP SYNONYM c##scott.klient_f;

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
    id int;
BEGIN
    id := c##scott.klient_seq.NEXTVAL;
    INSERT INTO c##scott.klient(id_klient, imie, nazwisko, nr_telefonu, email)
    VALUES (id, imie_, nazwisko_, nr_telefonu_, email_);
    INSERT INTO c##scottt.klient@DATABASE_LINK1(id_klient, pesel)
    VALUES (id, pesel_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/

---------- FUNKCJONALNOŚCI -----------
DROP SEQUENCE c##scott.wypozyczalnia_seq;
DROP SEQUENCE c##scott.wypozyczenie_seq;
DROP SEQUENCE c##scott.przedmiot_seq;
DROP VIEW c##scott.dostepne_przedmioty;

CREATE SEQUENCE c##scott.wypozyczalnia_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE SEQUENCE c##scott.wypozyczenie_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE SEQUENCE c##scott.przedmiot_seq
MINVALUE 0
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE OR REPLACE PROCEDURE c##scott.dodaj_wypozyczalnie
(
    nazwa_ IN VARCHAR2,
    adres_ IN VARCHAR2
)
AS
BEGIN
    INSERT INTO c##scott.wypozyczalnia(id_wypozyczalnia, nazwa, adres)
    VALUES (c##scott.wypozyczalnia_seq.NEXTVAL, nazwa_, adres_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/

CREATE OR REPLACE PROCEDURE c##scott.dodaj_przedmiot
(
    numer_seryjny_ IN VARCHAR2,
	id_wypozyczalnia_ IN int,
    id_rodzaj_przedmiotu_ IN int
	
)
AS
BEGIN
    INSERT INTO c##scott.przedmiot(id_przedmiot, id_wypozyczalnia, id_rodzaj_przedmiotu, numer_seryjny)
    VALUES (c##scott.przedmiot_seq.NEXTVAL, id_wypozyczalnia_, id_rodzaj_przedmiotu_, numer_seryjny_);
    commit;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/

INSERT INTO c##scott.wypozyczenie(id_wypozyczenie, id_przedmiot, id_klient, data_wypozyczenia, data_oddania)
    VALUES (c##scott.wypozyczenie_seq.NEXTVAL, 1, id_rodzaj_przedmiotu_, numer_seryjny_);
    commit;

CREATE VIEW c##scott.dostepne_przedmioty
AS
SELECT * FROM c##scott.przedmiot 
WHERE id_przedmiot NOT IN (
    SELECT DISTINCT id_przedmiot
    FROM c##scott.wypozyczenie
    WHERE CURRENT_TIMESTAMP between data_wypozyczenia AND data_oddania
);

CREATE OR REPLACE PROCEDURE c##scott.wypozycz_przedmiot
(
	id_przedmiot_ IN int,
    id_klient_ IN int
)
AS
    liczba int;
BEGIN
    SELECT count(*) INTO liczba FROM c##scott.przedmiot 
    WHERE id_przedmiot NOT IN (
        SELECT DISTINCT id_przedmiot
        FROM c##scott.wypozyczenie
        WHERE CURRENT_TIMESTAMP between data_wypozyczenia AND data_oddania
    ) AND id_przedmiot = id_przedmiot_;
    IF liczba >= 1 THEN
        INSERT INTO c##scott.wypozyczenie(id_wypozyczenie, id_przedmiot, id_klient, data_wypozyczenia, data_oddania)
        VALUES (c##scott.wypozyczenie_seq.NEXTVAL, id_przedmiot_, id_klient_, CURRENT_TIMESTAMP, TO_DATE('2044-DEC-25 17:30','YYYY-MON-DD HH24:MI','NLS_DATE_LANGUAGE=AMERICAN'));
        commit;
    END IF;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Error');
         rollback;
END;
/



---------- POPULACJA -----------
EXEC c##scott.dodaj_wypozyczalnie('Przykladowa', 'Wroclawska 17');
EXEC c##scott.dodaj_wypozyczalnie('Examplowa', 'Poznanska 33');

EXEC c##scott.dodaj_klienta('Adam', 'Pierwszy', 123456789, 'adam@gmail.com', 'pesel_adam');
EXEC c##scott.dodaj_klienta('Ewa', 'Druga', 987654321, 'ewa@gmail.com', 'pesel_ewa');

EXEC c##scott.dodaj_rodzaj_przedmiotu('PS5', 'konsola', 'Od SONY');
EXEC c##scott.dodaj_rodzaj_przedmiotu('XBOX Series X', 'konsola', 'Od Microsoft');
EXEC c##scott.dodaj_rodzaj_przedmiotu('JBL BT', 'Glosnik', 'Glosnik Bluetooth');

EXEC c##scott.dodaj_przedmiot('123', 1, 1)
EXEC c##scott.dodaj_przedmiot('153', 2, 1)
EXEC c##scott.dodaj_przedmiot('1g3', 3, 2)

INSERT INTO c##scott.wypozyczenie(id_wypozyczenie, id_przedmiot, id_klient, data_wypozyczenia, data_oddania)
    VALUES (c##scott.wypozyczenie_seq.NEXTVAL, 1, 1, CURRENT_TIMESTAMP, TO_DATE('2044-DEC-25 17:30','YYYY-MON-DD HH24:MI','NLS_DATE_LANGUAGE=AMERICAN'));
    commit;