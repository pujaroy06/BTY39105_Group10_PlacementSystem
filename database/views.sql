-- ============================================================
-- Group 10: University Placement and Recruitment Management System
-- File: views.sql
-- Purpose: Reusable views for eligibility checking and dashboard reporting
-- Member 4 Deliverable - Phase VI (Views)
-- ============================================================

USE placement_system;

-- ------------------------------------------------------------
-- VIEW 1: eligible_students_per_job
-- Shows which students meet the eligibility rules (CGPA and
-- backlog limit) for each open job, based on their MOST RECENT
-- semester's academic record. This is the core view behind the
-- "Advanced DBMS Component" required for our project - matching
-- students to jobs automatically instead of manually.
-- ------------------------------------------------------------
DROP VIEW IF EXISTS eligible_students_per_job;

CREATE VIEW eligible_students_per_job AS
SELECT
    j.job_id,
    j.job_title,
    s.student_id,
    s.name AS student_name,
    latest.sgpa AS current_sgpa,
    latest.backlog_count AS current_backlogs,
    je.min_cgpa,
    je.max_backlogs
FROM JOB j
JOIN JOB_ELIGIBILITY je ON j.job_id = je.job_id
JOIN STUDENT s ON s.program_id = je.program_id
JOIN (
    -- picks each student's most recent semester record
    SELECT ar1.student_id, ar1.sgpa, ar1.backlog_count
    FROM ACADEMIC_RECORD ar1
    WHERE ar1.semester = (
        SELECT MAX(ar2.semester)
        FROM ACADEMIC_RECORD ar2
        WHERE ar2.student_id = ar1.student_id
    )
) latest ON latest.student_id = s.student_id
WHERE latest.sgpa >= je.min_cgpa
  AND latest.backlog_count <= je.max_backlogs
  AND j.status = 'Open';

-- Example use: see who is eligible for job_id 1
-- SELECT * FROM eligible_students_per_job WHERE job_id = 1;

-- ------------------------------------------------------------
-- VIEW 2: placement_summary
-- One row per selected/offered student, showing their final
-- placement outcome. This is what powers the placement
-- dashboard - the Python backend can just SELECT from this
-- view instead of re-joining 5 tables every time.
-- ------------------------------------------------------------
DROP VIEW IF EXISTS placement_summary;

CREATE VIEW placement_summary AS
SELECT
    s.student_id,
    s.name AS student_name,
    p.program_name,
    c.company_name,
    j.job_title,
    o.package_offered_lpa,
    o.offer_status,
    o.joining_date
FROM OFFER o
JOIN APPLICATION a ON o.application_id = a.application_id
JOIN STUDENT s ON a.student_id = s.student_id
JOIN PROGRAM p ON s.program_id = p.program_id
JOIN JOB j ON a.job_id = j.job_id
JOIN COMPANY c ON j.company_id = c.company_id;

-- Example use: dashboard query for total placed students
-- SELECT COUNT(*) FROM placement_summary WHERE offer_status = 'Accepted';