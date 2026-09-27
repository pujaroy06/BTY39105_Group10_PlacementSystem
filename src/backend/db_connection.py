"""
db_connection.py
Group 10: University Placement and Recruitment Management System

Purpose: creates a MySQL database connection for the rest of the
backend to use. Credentials are read from environment variables
(never hard-coded), so the real password never ends up on GitHub.
Member 5 Deliverable - Phase VIII (Website Development)
"""

import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

# Loads variables from a local .env file (which is excluded from
# GitHub by .gitignore) into the environment, so os.environ.get()
# below can find them during local development.
load_dotenv()


def get_connection():
    """
    Opens and returns a new connection to the MySQL database.
    Every route that needs the database calls this function,
    uses the connection, and then closes it.
    """
    try:
        connection = mysql.connector.connect(
            host=os.environ.get("DB_HOST", "localhost"),
            user=os.environ.get("DB_USER", "root"),
            password=os.environ.get("DB_PASSWORD", ""),
            database=os.environ.get("DB_NAME", "placement_system")
        )
        return connection
    except Error as e:
        print(f"Database connection failed: {e}")
        return None


def call_procedure(procedure_name, args):
    """
    Helper function to call a MySQL stored procedure that has
    OUT parameters (like sp_check_eligibility or sp_submit_application)
    and return the OUT values as a list.

    Example:
        result = call_procedure('sp_submit_application', [9, 3])
        # result[-1] holds the value of the OUT parameter
    """
    connection = get_connection()
    if connection is None:
        return None

    try:
        cursor = connection.cursor()
        cursor.callproc(procedure_name, args)

        # stored procedure OUT parameters come back through
        # cursor.stored_results()
        results = []
        for result in cursor.stored_results():
            results.extend(result.fetchall())

        connection.commit()
        cursor.close()
        return results
    except Error as e:
        print(f"Procedure call failed: {e}")
        return None
    finally:
        connection.close()