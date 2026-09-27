"""
routes/job_routes.py
Group 10: University Placement and Recruitment Management System

Handles browsing job postings. Students see only the jobs they are
eligible for (using the eligible_students_per_job view built in
views.sql); the admin sees every posted job regardless of eligibility.
Member 5 Deliverable - Phase VIII (Website Development)
"""

from flask import Blueprint, render_template, session, redirect, url_for, flash
from db_connection import get_connection

job_routes = Blueprint('job_routes', __name__)


@job_routes.route('/jobs')
def list_jobs():
    if 'role' not in session:
        flash('Please log in first.')
        return redirect(url_for('auth_routes.login_page'))

    connection = get_connection()
    if connection is None:
        flash('Could not connect to the database. Please try again later.')
        return render_template('jobs.html', jobs=[])

    cursor = connection.cursor(dictionary=True)

    if session['role'] == 'student':
        # Only show jobs THIS student is eligible for, using the
        # eligible_students_per_job view we built in views.sql
        cursor.execute(
            """SELECT DISTINCT j.job_id, j.job_title, c.company_name,
                      j.package_lpa, j.location, j.application_deadline
               FROM eligible_students_per_job e
               JOIN JOB j ON e.job_id = j.job_id
               JOIN COMPANY c ON j.company_id = c.company_id
               WHERE e.student_id = %s""",
            (session['student_id'],)
        )
    else:
        # Admin sees every job regardless of eligibility
        cursor.execute(
            """SELECT j.job_id, j.job_title, c.company_name,
                      j.package_lpa, j.location, j.application_deadline, j.status
               FROM JOB j
               JOIN COMPANY c ON j.company_id = c.company_id
               ORDER BY j.posted_date DESC"""
        )

    jobs = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('jobs.html', jobs=jobs)


@job_routes.route('/jobs/<int:job_id>')
def job_detail(job_id):
    if 'role' not in session:
        flash('Please log in first.')
        return redirect(url_for('auth_routes.login_page'))

    connection = get_connection()
    if connection is None:
        flash('Could not connect to the database. Please try again later.')
        return redirect(url_for('job_routes.list_jobs'))

    cursor = connection.cursor(dictionary=True)

    cursor.execute(
        """SELECT j.*, c.company_name, c.industry
           FROM JOB j
           JOIN COMPANY c ON j.company_id = c.company_id
           WHERE j.job_id = %s""",
        (job_id,)
    )
    job = cursor.fetchone()

    cursor.execute(
        """SELECT p.program_name, je.min_cgpa, je.max_backlogs
           FROM JOB_ELIGIBILITY je
           JOIN PROGRAM p ON je.program_id = p.program_id
           WHERE je.job_id = %s""",
        (job_id,)
    )
    eligibility_rules = cursor.fetchall()

    cursor.close()
    connection.close()

    if job is None:
        flash('Job not found.')
        return redirect(url_for('job_routes.list_jobs'))

    return render_template('job_detail.html', job=job, eligibility_rules=eligibility_rules)