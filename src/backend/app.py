"""
app.py
Group 10: University Placement and Recruitment Management System

Purpose: Main Flask application entry point. Creates the Flask app,
sets configuration, registers all feature route files (blueprints),
and starts the development server.
Member 5 Deliverable - Phase VIII (Website Development)
"""

import os
from flask import Flask, redirect, url_for
from dotenv import load_dotenv

from routes.auth_routes import auth_routes
from routes.job_routes import job_routes
from routes.application_routes import application_routes
from routes.admin_routes import admin_routes
from routes.dashboard_routes import dashboard_routes

load_dotenv()

app = Flask(
    __name__,
    template_folder="../frontend",   # our .html files live here
    static_folder="../frontend",      # style.css also lives here
    static_url_path="/static"
)

# Secret key is required for Flask sessions (keeping someone logged in).
# Read from environment - never hard-code this in real code.
app.secret_key = os.environ.get("SECRET_KEY", "dev-only-fallback-key")

# Register each feature's routes with the main app
app.register_blueprint(auth_routes)
app.register_blueprint(job_routes)
app.register_blueprint(application_routes)
app.register_blueprint(admin_routes)
app.register_blueprint(dashboard_routes)


@app.route("/")
def home():
    """Visiting the root URL sends the person to the login page."""
    return redirect(url_for("auth_routes.login_page"))


if __name__ == "__main__":
    app.run(debug=True)