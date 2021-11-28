---------- POPULACJA -----------
EXEC c##robd.dodaj_wypozyczalnie('Przykladowa', 'Wroclawska 17');
EXEC c##robd.dodaj_wypozyczalnie('Examplowa', 'Poznanska 33');

EXEC c##robd.dodaj_klienta('Adam', 'Pierwszy', 123456789, 'adam@gmail.com', 'pesel_adam');
EXEC c##robd.dodaj_klienta('Ewa', 'Druga', 987654321, 'ewa@gmail.com', 'pesel_ewa');

EXEC c##robd.dodaj_rodzaj_przedmiotu('PS5', 'konsola', 'Od SONY');
EXEC c##robd.dodaj_rodzaj_przedmiotu('XBOX Series X', 'konsola', 'Od Microsoft');
EXEC c##robd.dodaj_rodzaj_przedmiotu('JBL BT', 'Glosnik', 'Glosnik Bluetooth');

EXEC c##robd.dodaj_przedmiot('1d123', 1, 1);
EXEC c##robd.dodaj_przedmiot('3d153', 2, 1);
EXEC c##robd.dodaj_przedmiot('121g3', 3, 2);

INSERT INTO c##robd.wypozyczenie(id_wypozyczenie, id_przedmiot, id_klient, data_wypozyczenia, data_oddania)
    VALUES (c##robd.wypozyczenie_seq.NEXTVAL, 1, 1, CURRENT_TIMESTAMP, TO_DATE('2044-DEC-25 17:30','YYYY-MON-DD HH24:MI','NLS_DATE_LANGUAGE=AMERICAN'));
    commit;
	
INSERT INTO c##robd.wypozyczenie(id_wypozyczenie, id_przedmiot, id_klient, data_wypozyczenia, data_oddania)
    VALUES (c##robd.wypozyczenie_seq.NEXTVAL, 1, id_rodzaj_przedmiotu_, numer_seryjny_);
    commit;