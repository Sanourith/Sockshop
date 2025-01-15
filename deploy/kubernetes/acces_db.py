import pymysql


def connect_and_query():
    host = "127.0.0.1"
    port = 3306
    user = "root"
    password = "fake_password"
    database = "socksdb"

    try:
        connection = pymysql.connect(
            host=host, port=port, user=user, password=password, database=database
        )
        print("Connexion OK")

        query = "SHOW TABLES;"
        with connection.cursor() as cursor:
            cursor.execute(query)
            tables = cursor.fetchall()
            print("Tables dans la DB:")

            for table in tables:
                print(table[0])

    except pymysql.MySQLError as e:
        print(f"Erreur {e}")

    finally:
        if "connection" in locals() and connection.open:
            connection.close()
            print("Connexion terminée.")


if __name__ == "__main__":
    connect_and_query()


# import mysql.connector
# from mysql.connector import Error


# def connect_mysql(host, port, user, password, database):
#     """Etablie une connexion à ma DB"""
#     try:
#         connection = mysql.connector.connect(
#             host=host, port=port, user=user, password=password, database=database
#         )
#         if connection.is_connected():
#             print("Connexion DB réussie.")
#             return connection
#     except Error as e:
#         print(f"Erreur de connexion DB. {e}")
#         return None


# def execute_query(connection, query):
#     """Exécute une query dans la DB"""
#     try:
#         cursor = connection.cursor()
#         cursor.execute(query)
#         results = cursor.fetchall()
#         return results
#     except Error as e:
#         print(f"Erreur avec la requête : {e}")
#         return []


# def main():
#     # Connexion
#     host = "localhost"
#     port = 3306
#     user = "root"
#     password = "password"
#     database = "socksdb"

#     query = "SHOW TABLES;"

#     connection = connect_mysql(host, port, user, password, database)

#     if connection:
#         results = execute_query(connection, query)

#         for row in results:
#             print(row)

#         connection.close()
#     else:
#         print("CA A PAS MARCHE.")
