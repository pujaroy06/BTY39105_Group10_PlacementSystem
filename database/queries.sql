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

-- ============================================================
-- SECTION C: JOIN QUERIES (5)
-- Member 4 Deliverable - Phase VI (SQL Query Development, advanced part)
-- ============================================================

-- 1. List all applications with student name, job title and company name
SELECT a.application_id, s.name AS student_name, j.job_title, c.company_name, a.status
FROM APPLICATION a
JOIN STUDENT s ON a.student_id = s.student_id
JOIN JOB j ON a.job_id = j.job_id
JOIN COMPANY c ON j.company_id = c.company_id;

-- 2. List all offers with student name, job title and offered package
SELECT o.offer_id, s.name AS student_name, j.job_title, o.package_offered_lpa, o.offer_status
FROM OFFER o
JOIN APPLICATION a ON o.application_id = a.application_id
JOIN STUDENT s ON a.student_id = s.student_id
JOIN JOB j ON a.job_id = j.job_id;

-- 3. List all test results with student name and job title
SELECT t.test_result_id, s.name AS student_name, j.job_title, t.test_score, t.result_status
FROM TEST_RESULT t
JOIN APPLICATION a ON t.application_id = a.application_id
JOIN STUDENT s ON a.student_id = s.student_id
JOIN JOB j ON a.job_id = j.job_id;

-- 4. List all interviews with student name and company name
SELECT i.interview_id, s.name AS student_name, c.company_name, i.interview_date, i.interview_status
FROM INTERVIEW i
JOIN APPLICATION a ON i.application_id = a.application_id
JOIN STUDENT s ON a.student_id = s.student_id
JOIN JOB j ON a.job_id = j.job_id
JOIN COMPANY c ON j.company_id = c.company_id;

-- 5. List all eligibility rules with job title and eligible program name
SELECT je.eligibility_id, j.job_title, p.program_name, je.min_cgpa, je.max_backlogs
FROM JOB_ELIGIBILITY je
JOIN JOB j ON je.job_id = j.job_id
JOIN PROGRAM p ON je.program_id = p.program_id;

-- ============================================================
-- SECTION D: SUBQUERIES (3)
-- ============================================================

-- 1. Students whose semester 6 SGPA is above the average semester 6 SGPA of everyone
SELECT student_id, semester, sgpa
FROM ACADEMIC_RECORD
WHERE semester = 6
AND sgpa > (SELECT AVG(sgpa) FROM ACADEMIC_RECORD WHERE semester = 6);

-- 2. Jobs offering a package higher than the average package of all jobs
SELECT job_title, package_lpa
FROM JOB
WHERE package_lpa > (SELECT AVG(package_lpa) FROM JOB);

-- 3. Students who have applied to at least one job
SELECT name, email
FROM STUDENT
WHERE student_id IN (SELECT DISTINCT student_id FROM APPLICATION);

-- ============================================================
-- SECTION E: CORRELATED SUBQUERIES (2)
-- ============================================================

-- 1. Students whose semester 6 SGPA improved compared to their own semester 5 SGPA
SELECT a1.student_id, a1.sgpa AS sem6_sgpa
FROM ACADEMIC_RECORD a1
WHERE a1.semester = 6
AND a1.sgpa > (
    SELECT a2.sgpa
    FROM ACADEMIC_RECORD a2
    WHERE a2.student_id = a1.student_id AND a2.semester = 5
);

-- 2. Jobs whose package is above the average package offered by the SAME company
SELECT j1.job_title, j1.package_lpa, j1.company_id
FROM JOB j1
WHERE j1.package_lpa > (
    SELECT AVG(j2.package_lpa)
    FROM JOB j2
    WHERE j2.company_id = j1.company_id
);