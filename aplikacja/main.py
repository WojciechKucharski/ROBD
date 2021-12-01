import orm


def choice_calculator(choice: str) -> int:
    try:
        return int(choice)
    except:
        return 0


def print_all_tables(db):
    for i, x in enumerate(db.all_tables):
        print(f"{i}. {x.title}")


def handle_add(choice: int, db) -> bool:
    if choice not in [0, 1, 2, 3]:
        return False
    else:
        if choice == 0:
            done = db.add_client(name=input("Imie: "), surname=input("Nazwisko: "),
                                 phone_number=int(input("Numer telefonu: ")), email=input("Email: "),
                                 pesel=input("Pesel: "))
            if done:
                print("Dodano klienta.")
            else:
                print("Operacja nie powiodła się.")

        elif choice == 1:
            any = 0
            for i, x in enumerate(db.all_tables_dict["item_type"].records):
                any = 1
                id = x["id_rodzaj_przedmiotu"]
                print(f"{id}. {x}")
            if any == 0:
                print("Nie ma dostępnych typów przedmiotów")
                return False
            item_type_key = int(input("Podaj id rodzaju: "))
            any = 0
            for i, x in enumerate(db.all_tables_dict["rental"].records):
                any = 1
                id = x["id_wypozyczalnia"]
                print(f"{id}. {x}")
            rental_key = int(input("Podaj id wypożyczalni: "))
            db.add_item(name=input("Nazwa: "), rental_key=rental_key, item_type_key=item_type_key)

        elif choice == 2:
            done = db.add_item_type(name=input("Nazwa: "), type=input("Typ: "), description=input("Opis: "))
            if done:
                print("Dodano rodzaj przedmiotu.")
            else:
                print("Operacja nie powiodła się.")
        elif choice == 3:
            done = db.add_rental(name=input("Nazwa: "), adress=input("Adres: "))
            if done:
                print("Dodano wypożyczalnię.")
            else:
                print("Operacja nie powiodła się.")


def handle_choice(choice: int, db):
    if (choice == 1):
        print("Którą tabelę wyświetlić?")
        print_all_tables(db)
        i = choice_calculator(input())
        for x in db.all_tables[i].records:
            print(x)
        print("############################")
    if (choice == 2):
        print("Do której tabeli dodać rekord?")
        for i, x in enumerate(db.all_tables):
            if (i > 3):
                break
            print(f"{i}. {x.title}")
        id = choice_calculator(input())
        handle_add(id, db)

    if (choice == 3):
        print("Który przedmiot wypożyczyć?")
        any = 0
        for i, x in enumerate(db.all_tables_dict["item"].records):
            if (x["dostepny"] == 1):
                any = 1
                id = x["id_przedmiot"]
                print(f"{id}. {x}")
        if (any == 0):
            print("Nic do wypożyczenia.")
            return 0
        item_key = choice_calculator(input())
        print("Komu wypożyczyć?")
        any = 0
        for i, x in enumerate(db.all_tables_dict["client"].records):
            any = 1
            id = x["id_klient"]
            print(f"{id}. {x}")
        if (any == 0):
            print("Nie ma komu wypożyczyć.")
            return 0
        client_key = choice_calculator(input())
        rented = db.rent_item(item_key, client_key)
        if rented:
            print("Wypożyczono.")
        else:
            print("Operacja nie powiodła się.")

    if (choice == 4):
        print("Który przedmiot zwrócić?")
        any = 0
        for i, x in enumerate(db.all_tables_dict["item"].records):
            if (x["dostepny"] == 0):
                any = 1
                id = x["id_przedmiot"]
                print(f"{id}. {x}")
        if (any == 0):
            print("Nic do zwórcenia.")
            return 0
        id = choice_calculator(input())
        returned = db.return_item(id)
        if returned:
            print("Zwrócono")
        else:
            print("Operacja nie powiodła się.")


def main():
    ips = ["192.168.56.1", "192.168.56.102"]
    ip_ = 0
    while (ip_ not in [1, 2]):
        print("Do którego ip się podłączyć?")
        print(f"1. {ips[0]}\n2. {ips[1]}")
        ip_ = choice_calculator(input())

    with orm.Database(user="c##robd", password="123", ip=ips[ip_ - 1]) as db:
        try:
            choice = -1
            while (choice != 0):
                db.update_all()
                if (choice > 0):
                    handle_choice(choice, db)
                print("############################")
                print(
                    "APLIKACJA DOSTĘPOWA - ROBD\n1. Wyświetl zawartość tabeli.\n2. Dodaj rekord. \n3. Wypożycz przedmiot.\n4. Zwróć przedmiot.\n0. Wyjdź.\n")
                choice = choice_calculator(input())
        except Exception as e:
            print(e)
            print("Coś poszło nie tak")


if __name__ == "__main__":
    main()
