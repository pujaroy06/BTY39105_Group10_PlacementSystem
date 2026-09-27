"""
routes/dashboard_routes.py
Group 10: University Placement and Recruitment Management System

Handles the placement statistics dashboard for the admin, built on
top of the placement_summary view from views.sql. Every number here
comes directly from a database query - nothing is hard-coded, which
is a specific requirement in Section 5 of the course proforma.
Member 5 Deliverable - Phase VIII (Website Development)
"""

from flask import Blueprint, render_template, session, redirect, url_for, flash
from db_connection import get_connection

dashboard_routes = Blueprint('dashboard_routes', __name__)


@dashboard_routes.route('/admin/dashboard')
def admin_dashboard():
    if session.get('role') != 'admin':
        flash('Admin access required.')
        return redirect(url_for('auth_routes.login_page'))

    connection = get_connection()
    if connection is None:
        flash('Could not connect to the database. Please try again later.')
        return render_template('dashboard.html')

    cursor = connection.cursor(dictionary=True)

    # 1. Total students who have accepted an offer
    cursor.execute(
        "SELECT COUNT(*) AS total_placed FROM placement_summary WHERE offer_status = 'Accepted'"
    )
    total_placed = cursor.fetchone()['total_placed']

    # 2. Average accepted package
    cursor.execute(
        "SELECT AVG(package_offered_lpa) AS avg_package FROM placement_summary WHERE offer_status = 'Accepted'"
    )
    avg_package = cursor.fetchone()['avg_package']

    # 3. Placements grouped by company
    cursor.execute(
        """SELECT company_name, COUNT(*) AS placed_count
           FROM placement_summary
           WHERE offer_status = 'Accepted'
           GROUP BY company_name
           ORDER BY placed_count DESC"""
    )
    company_wise = cursor.fetchall()

    # 4. Placements grouped by program/branch
    cursor.execute(
        """SELECT program_name, COUNT(*) AS placed_count
           FROM placement_summary
           WHERE offer_status = 'Accepted'
           GROUP BY program_name
           ORDER BY placed_count DESC"""
    )
    branch_wise = cursor.fetchall()

    # 5. Applications grouped by status - a pipeline overview
    cursor.execute(
        "SELECT status, COUNT(*) AS total FROM APPLICATION GROUP BY status"
    )
    application_status_counts = cursor.fetchall()

    # 6. Full placement list for the dashboard table
    cursor.execute(
        """SELECT student_name, program_name, company_name, job_title,
                  package_offered_lpa, offer_status, joining_date
           FROM placement_summary
           ORDER BY package_offered_lpa DESC"""
    )
    placements = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template(
        'dashboard.html',
        total_placed=total_placed,
        avg_package=avg_package,
        company_wise=company_wise,
        branch_wise=branch_wise,
        application_status_counts=application_status_counts,
        placements=placements
    )