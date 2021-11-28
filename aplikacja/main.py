import cx_Oracle

connection = cx_Oracle.connect(
    user="c##robd",
    password="123",
    dsn="192.168.56.1/xe")

print("Successfully connected to Oracle Database")

cursor = connection.cursor()

iter = cursor.execute("SELECT * FROM c##scott.klient_r")
for i in iter:
    print(i)

connection.close()