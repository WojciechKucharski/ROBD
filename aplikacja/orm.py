import cx_Oracle
from typing import List


class Table:
    def __init__(self, cursor, query: str, columns: List[str]):
        self.cursor, self.query, self.columns = cursor, query, columns
        self.stored_records = []
        self.update()

    def update(self):
        self.stored_records = [{
            column_name: record[i] for i, column_name in enumerate(self.columns)
        } for record in self.cursor.execute(self.query)]

    def is_in(self, key: int) -> bool:
        return bool(key in self.get_ids)

    @property
    def records(self) -> List:
        self.update()
        return self.stored_records

    @property
    def get_ids(self) -> List[int]:
        return [record[self.columns[0]] for record in self.records]

    @property
    def title(self):
        return self.columns[0].replace("id_", "")


class Item(Table):
    def update(self):
        self.stored_records = [
                                  {
                                      "id_przedmiot": record[0],
                                      "id_wypozyczalnia": record[2],
                                      "id_rodzaj_przedmiotu": record[2],
                                      "nazwa_przedmiotu": record[3],
                                      "dostepny": 1
                                  } for record in self.cursor.execute(self.query + "dostepne_przedmioty")
                              ] + [
                                  {
                                      "id_przedmiot": record[0],
                                      "id_wypozyczalnia": record[2],
                                      "id_rodzaj_przedmiotu": record[2],
                                      "nazwa_przedmiotu": record[3],
                                      "dostepny": 0
                                  } for record in
                                  self.cursor.execute(self.query + "niedostepne_przedmioty")
                              ]


class Database:
    def __init__(self, user, password, ip: str):
        self.connection = cx_Oracle.connect(
            user=user,
            password=password,
            dsn=ip)
        self.user, self.password, self.ip = user, password, ip
        self.cursor = self.connection.cursor()

        self.table_names = [name[0] for name in self.cursor.execute(
            f"SELECT table_name FROM all_tables WHERE owner = '{self.user.upper()}'")]
        self.column_names = {
            table_name: [desc[0] for desc in self.cursor.execute(f"select * from {self.user}.{table_name}").description]
            for table_name in self.table_names
        }

        self.client = Table(cursor=self.cursor, query=f"SELECT * FROM {self.user}.klient_r", columns=["id_klient",
                                                                                                      "imie",
                                                                                                      "nazwisko",
                                                                                                      "nr_telefonu",
                                                                                                      "email", "pesel"])

        self.item = Item(cursor=self.cursor, query=f"SELECT * FROM {self.user}.",
                         columns=["id_przedmiot", "id_wypozyczalnia", "id_rodzaj_przedmiotu", "nazwa_przedmiotu",
                                  "dostepny"])

        self.item_type = Table(cursor=self.cursor, query=f"SELECT * FROM {self.user}.rodzaj_przedmiotu_r",
                               columns=["id_rodzaj_przedmiotu", "nazwa", "typ", "opis"])
        self.rental = Table(cursor=self.cursor, query=f"SELECT * FROM {self.user}.wypozyczalnia",
                            columns=["id_wypozyczalnia", "nazwa", "adres"])
        self.rent_info = Table(cursor=self.cursor, query=f"SELECT * FROM {self.user}.wypozyczenie",
                               columns=["id_wypozyczenie", "id_przedmiot", "id_klient", "data_wypozyczenia",
                                        "data_oddania"])

    def return_item(self, item_key: int) -> bool:
        returned = False
        for x in self.all_tables[4].records:
            if (x["id_przedmiot"] == item_key):
                self.cursor.callproc(f"{self.user}.oddaj_przedmiot", [x["id_wypozyczenie"]])
                returned = True
        return returned

    def rent_item(self, item_key: int, client_key: int) -> bool:
        self.update_all()
        if not self.all_tables[0].is_in(client_key):
            return False
        if not self.all_tables[1].is_in(item_key):
            return False
        self.cursor.callproc(f"{self.user}.wypozycz_przedmiot", [item_key, client_key])
        self.update_all()
        return True

    def add_client(self, name: str, surname: str, phone_number: int, email: str, pesel: str) -> bool:
        self.cursor.callproc(f"{self.user}.dodaj_klienta", [name, surname, phone_number, email, pesel])
        return True

    def add_item(self, name: str, rental_key: int, item_type_key: int) -> bool:
        self.update_all()
        if not self.all_tables_dict["rental"].is_in(rental_key):
            return False
        if not self.all_tables_dict["item_type"].is_in(item_type_key):
            return False
        self.cursor.callproc(f"{self.user}.dodaj_przedmiot", [name, rental_key, item_type_key])
        return True

    def add_item_type(self, name: str, type: str, description: str) -> bool:
        self.cursor.callproc(f"{self.user}.dodaj_rodzaj_przedmiotu", [name, type, description])
        return True

    def add_rental(self, name: str, adress: str) -> bool:
        self.cursor.callproc(f"{self.user}.dodaj_wypozyczalnie", [name, adress])
        return True

    def update_all(self):
        for x in self.all_tables:
            x.update()

    def close_connection(self):
        self.connection.close()

    @property
    def all_tables(self):
        return [self.client, self.item, self.item_type, self.rental, self.rent_info]

    @property
    def all_tables_dict(self):
        return {"client": self.client, "item": self.item, "item_type": self.item_type, "rental": self.rental,
                "rent_info": self.rent_info}

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close_connection()
        return False
