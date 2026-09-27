"""
routes/admin_routes.py
Group 10: University Placement and Recruitment Management System

Handles everything only the placement officer (admin) can do:
posting companies and jobs, defining job eligibility rules, moving
applications through the pipeline, recording test results and
interviews, and generating offers (via sp_generate_offer, which
demonstrates transaction control from procedures.sql).
Member 5 Deliverable - Phase VIII (Website Development)
"""

from flask import Blueprint, render_template, request, session, redirect, url_for, flash
from db_connection import get_connection, call_procedure

admin_routes = Blueprint('admin_routes', __name__)


def _admin_only():
    """Returns True if the current session belongs to the admin."""
    return session.get('role') == 'admin'


# ------------------------------------------------------------
# COMPANY MANAGEMENT
# ------------------------------------------------------------
@admin_routes.route('/admin/companies/new', methods=['GET', 'POST'])
def add_company():
    if not _admin_only():
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    if request.method == 'POST':
        name = request.form.get('company_name')
        industry = request.form.get('industry')
        website = request.form.get('website')
        contact_email = request.form.get('contact_email')
        contact_phone = request.form.get('contact_phone')

        if not name or not contact_email:
            flash('Company name and contact email are required.')
            return render_template('admin.html')

        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute(
            """INSERT INTO COMPANY (company_name, industry, website, contact_email, contact_phone)
               VALUES (%s, %s, %s, %s, %s)""",
            (name, industry, website, contact_email, contact_phone)
        )
        connection.commit()
        cursor.close()
        connection.close()

        flash('Company added successfully.')
        return redirect(url_for('admin_routes.add_company'))

    return render_template('admin.html')


# ------------------------------------------------------------
# JOB MANAGEMENT
# ------------------------------------------------------------
@admin_routes.route('/admin/jobs/new', methods=['GET', 'POST'])
def add_job():
    if not _admin_only():
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    if request.method == 'POST':
        company_id = request.form.get('company_id')
        job_title = request.form.get('job_title')
        job_description = request.form.get('job_description')
        package_lpa = request.form.get('package_lpa')
        job_type = request.form.get('job_type')
        location = request.form.get('location')
        positions_available = request.form.get('positions_available')
        posted_date = request.form.get('posted_date')
        application_deadline = request.form.get('application_deadline')

        if not all([company_id, job_title, package_lpa, job_type, positions_available,
                    posted_date, application_deadline]):
            flash('Please fill in all required job fields.')
            return render_template('admin.html')

        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute(
            """INSERT INTO JOB (company_id, job_title, job_description, package_lpa,
                                 job_type, location, positions_available,
                                 posted_date, application_deadline, status)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'Open')""",
            (company_id, job_title, job_description, package_lpa, job_type,
             location, positions_available, posted_date, application_deadline)
        )
        connection.commit()
        cursor.close()
        connection.close()

        flash('Job posted successfully. Add eligibility rules for it next.')
        return redirect(url_for('admin_routes.add_job'))

    return render_template('admin.html')


@admin_routes.route('/admin/jobs/<int:job_id>/eligibility', methods=['POST'])
def add_job_eligibility(job_id):
    if not _admin_only():
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    program_id = request.form.get('program_id')
    min_cgpa = request.form.get('min_cgpa')
    max_backlogs = request.form.get('max_backlogs')

    if not all([program_id, min_cgpa]):
        flash('Program and minimum CGPA are required for an eligibility rule.')
        return redirect(url_for('job_routes.job_detail', job_id=job_id))

    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute(
        """INSERT INTO JOB_ELIGIBILITY (job_id, program_id, min_cgpa, max_backlogs)
           VALUES (%s, %s, %s, %s)""",
        (job_id, program_id, min_cgpa, max_backlogs or 0)
    )
    connection.commit()
    cursor.close()
    connection.close()

    flash('Eligibility rule added.')
    return redirect(url_for('job_routes.job_detail', job_id=job_id))


# ------------------------------------------------------------
# APPLICATION PIPELINE MANAGEMENT
# ------------------------------------------------------------
@admin_routes.route('/admin/applications')
def view_applications():
    if not _admin_only():
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute(
        """SELECT a.application_id, s.name AS student_name, j.job_title,
                  c.company_name, a.application_date, a.status
           FROM APPLICATION a
           JOIN STUDENT s ON a.student_id = s.student_id
           JOIN JOB j ON a.job_id = j.job_id
           JOIN COMPANY c ON j.company_id = c.company_id
           ORDER BY a.application_date DESC"""
    )
    applications = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('admin.html', applications=applications)


@admin_routes.route('/admin/applications/<int:application_id>/status', methods=['POST'])
def update_application_status(application_id):
    if not _admin_only():
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    new_status = request.form.get('status')
    valid_statuses = ('Applied', 'Shortlisted', 'Interviewed', 'Selected', 'Rejected')

    if new_status not in valid_statuses:
        flash('Invalid status value.')
        return redirect(url_for('admin_routes.view_applications'))

    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute(
        "UPDATE APPLICATION SET status = %s WHERE application_id = %s",
        (new_status, application_id)
    )
    connection.commit()
    cursor.close()
    connection.close()

    flash(f'Application {application_id} updated to {new_status}.')
    return redirect(url_for('admin_routes.view_applications'))


@admin_routes.route('/admin/applications/<int:application_id>/test-result', methods=['POST'])
def add_test_result(application_id):
    if not _admin_only():
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    test_date = request.form.get('test_date')
    test_score = request.form.get('test_score')
    max_score = request.form.get('max_score')
    result_status = request.form.get('result_status')

    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute(
        """INSERT INTO TEST_RESULT (application_id, test_date, test_score, max_score, result_status)
           VALUES (%s, %s, %s, %s, %s)""",
        (application_id, test_date, test_score, max_score, result_status)
    )
    connection.commit()
    cursor.close()
    connection.close()

    flash('Test result recorded.')
    return redirect(url_for('admin_routes.view_applications'))


@admin_routes.route('/admin/applications/<int:application_id>/interview', methods=['POST'])
def add_interview(application_id):
    if not _admin_only():
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    interview_date = request.form.get('interview_date')
    interview_mode = request.form.get('interview_mode')
    interviewer_name = request.form.get('interviewer_name')
    interview_status = request.form.get('interview_status', 'Scheduled')
    feedback = request.form.get('feedback')

    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute(
        """INSERT INTO INTERVIEW (application_id, interview_date, interview_mode,
                                   interviewer_name, interview_status, feedback)
           VALUES (%s, %s, %s, %s, %s, %s)""",
        (application_id, interview_date, interview_mode, interviewer_name,
         interview_status, feedback)
    )
    connection.commit()
    cursor.close()
    connection.close()

    flash('Interview recorded.')
    return redirect(url_for('admin_routes.view_applications'))


@admin_routes.route('/admin/applications/<int:application_id>/offer', methods=['POST'])
def generate_offer(application_id):
    if not _admin_only():
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    package = request.form.get('package_offered_lpa')
    joining_date = request.form.get('joining_date')

    if not package or not joining_date:
        flash('Package and joining date are required to generate an offer.')
        return redirect(url_for('admin_routes.view_applications'))

    # sp_generate_offer(IN application_id, IN package, IN joining_date, OUT result_message)
    # this is the transaction-demonstration procedure from procedures.sql -
    # it either fully creates the offer AND updates the application, or
    # rolls back both if anything fails (e.g. a duplicate offer)
    result = call_procedure(
        'sp_generate_offer',
        (application_id, package, joining_date, '')
    )

    if result is None:
        flash('Something went wrong while generating the offer.')
    else:
        flash(result[3])  # the OUT parameter's final message

    return redirect(url_for('admin_routes.view_applications'))