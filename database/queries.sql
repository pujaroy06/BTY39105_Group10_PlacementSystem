-- ============================================================
-- Group 10: University Placement and Recruitment Management System
-- File: queries.sql
-- Purpose: Basic SELECT queries and aggregate/GROUP BY queries
--          (run against the data inserted by insert_data.sql)
-- Member 3 Deliverable - Phase VI (SQL Query Development, basic part)
-- ============================================================

USE placement_system;

-- ============================================================
-- SECTION A: BASIC SELECT QUERIES (10)
-- ============================================================

-- 1. List all students
SELECT * FROM STUDENT;

-- 2. List all students belonging to program_id 1 (B.Tech CSE)
SELECT student_id, name, email
FROM STUDENT
WHERE program_id = 1;

-- 3. List all jobs offering a package greater than 5 LPA
SELECT job_title, package_lpa, job_type
FROM JOB
WHERE package_lpa > 5.00;

-- 4. List all jobs sorted by package, highest first
SELECT job_title, package_lpa
FROM JOB
ORDER BY package_lpa DESC;

-- 5. List all distinct job locations currently posted
SELECT DISTINCT location
FROM JOB;

-- 6. List students who enrolled between 2021 and 2022
SELECT student_id, name, enrollment_year
FROM STUDENT
WHERE enrollment_year BETWEEN 2021 AND 2022;

-- 7. List companies whose industry is 'IT Services'
SELECT company_name, contact_email
FROM COMPANY
WHERE industry = 'IT Services';

-- 8. List applications that are either Selected or Interviewed
SELECT application_id, student_id, job_id, status
FROM APPLICATION
WHERE status IN ('Selected', 'Interviewed');

-- 9. List students whose name starts with the letter 'A'
SELECT name, email
FROM STUDENT
WHERE name LIKE 'A%';

-- 10. List jobs whose title contains the word 'Engineer'
SELECT job_title, company_id
FROM JOB
WHERE job_title LIKE '%Engineer%';

-- ============================================================
-- SECTION B: AGGREGATE / GROUP BY QUERIES (5)
-- ============================================================

-- 1. Count how many students belong to each program
SELECT program_id, COUNT(*) AS total_students
FROM STUDENT
GROUP BY program_id;

-- 2. Count applications grouped by their status
--    (quick check: how many are Applied / Shortlisted / Selected / Rejected)
SELECT status, COUNT(*) AS total_applications
FROM APPLICATION
GROUP BY status;

-- 3. Average package offered, grouped by job type (Full-time vs Internship)
SELECT job_type, AVG(package_lpa) AS avg_package
FROM JOB
GROUP BY job_type;

-- 4. Count how many jobs each company has posted
SELECT company_id, COUNT(*) AS jobs_posted
FROM JOB
GROUP BY company_id;

-- 5. Highest and lowest SGPA recorded, grouped by semester
SELECT semester, MAX(sgpa) AS highest_sgpa, MIN(sgpa) AS lowest_sgpa
FROM ACADEMIC_RECORD
GROUP BY semester;