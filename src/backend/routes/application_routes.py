"""
routes/application_routes.py
Group 10: University Placement and Recruitment Management System

Handles a student applying to a job and viewing their own application
history. The actual "Apply" action calls sp_submit_application from
procedures.sql, which enforces eligibility and duplicate-application
checks INSIDE the database - this route just passes the result along.
Member 5 Deliverable - Phase VIII (Website Development)
"""

from flask import Blueprint, render_template, session, redirect, url_for, flash
from db_connection import get_connection, call_procedure

application_routes = Blueprint('application_routes', __name__)


@application_routes.route('/apply/<int:job_id>', methods=['POST'])
def apply_to_job(job_id):
    if session.get('role') != 'student':
        flash('Only students can apply to jobs.')
        return redirect(url_for('auth_routes.login_page'))

    student_id = session['student_id']

    # sp_submit_application(IN student_id, IN job_id, OUT result_message)
    # the third value '' is just a placeholder for the OUT parameter
    result = call_procedure('sp_submit_application', (student_id, job_id, ''))

    if result is None:
        flash('Something went wrong while submitting your application.')
    else:
        flash(result[2])  # the OUT parameter's final message

    return redirect(url_for('application_routes.my_applications'))


@application_routes.route('/my-applications')
def my_applications():
    if session.get('role') != 'student':
        flash('Please log in as a student to view your applications.')
        return redirect(url_for('auth_routes.login_page'))

    student_id = session['student_id']

    connection = get_connection()
    if connection is None:
        flash('Could not connect to the database. Please try again later.')
        return render_template('apply.html', applications=[])

    cursor = connection.cursor(dictionary=True)
    cursor.execute(
        """SELECT a.application_id, j.job_title, c.company_name,
                  a.application_date, a.status
           FROM APPLICATION a
           JOIN JOB j ON a.job_id = j.job_id
           JOIN COMPANY c ON j.company_id = c.company_id
           WHERE a.student_id = %s
           ORDER BY a.application_date DESC""",
        (student_id,)
    )
    applications = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('apply.html', applications=applications)