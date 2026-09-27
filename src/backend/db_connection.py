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
    OUT parameters (like sp_check_eligibility, sp_submit_application,
    or sp_generate_offer).

    Important detail: mysql-connector-python returns OUT/INOUT
    parameter values through the TUPLE that callproc() itself
    returns - not through cursor.stored_results() (that method is
    only for SELECT result sets a procedure produces, which none
    of ours do). So the value returned here is the same length as
    `args`, with the OUT parameter slots filled in by the procedure.

    Example:
        # sp_submit_application(IN student_id, IN job_id, OUT message)
        result = call_procedure('sp_submit_application', (9, 3, ''))
        message = result[2]   # the OUT parameter's final value
    """
    connection = get_connection()
    if connection is None:
        return None

    try:
        cursor = connection.cursor()
        result_args = cursor.callproc(procedure_name, args)
        connection.commit()
        cursor.close()
        return result_args
    except Error as e:
        print(f"Procedure call failed: {e}")
        return None
    finally:
        connection.close()