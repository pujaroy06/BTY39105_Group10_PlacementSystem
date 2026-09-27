-- ============================================================
-- Group 10: University Placement and Recruitment Management System
-- File: schema.sql
-- Purpose: Creates the database and all 10 tables with keys,
--          constraints and indexes, based on docs/Relational_Schema.md
-- Member 3 Deliverable - Phase V (Database Development)
-- ============================================================

CREATE DATABASE IF NOT EXISTS placement_system;
USE placement_system;

-- Drop tables if they already exist (useful while testing, order matters
-- because of foreign keys - children dropped before parents)
DROP TABLE IF EXISTS OFFER;
DROP TABLE IF EXISTS INTERVIEW;
DROP TABLE IF EXISTS TEST_RESULT;
DROP TABLE IF EXISTS APPLICATION;
DROP TABLE IF EXISTS JOB_ELIGIBILITY;
DROP TABLE IF EXISTS JOB;
DROP TABLE IF EXISTS COMPANY;
DROP TABLE IF EXISTS ACADEMIC_RECORD;
DROP TABLE IF EXISTS STUDENT;
DROP TABLE IF EXISTS PROGRAM;

-- ------------------------------------------------------------
-- 1. PROGRAM
-- ------------------------------------------------------------
CREATE TABLE PROGRAM (
    program_id      INT AUTO_INCREMENT PRIMARY KEY,
    program_name    VARCHAR(100) NOT NULL,
    department      VARCHAR(100) NOT NULL,
    duration_years  INT NOT NULL
);

-- ------------------------------------------------------------
-- 2. STUDENT
-- ------------------------------------------------------------
CREATE TABLE STUDENT (
    student_id       INT AUTO_INCREMENT PRIMARY KEY,
    program_id       INT NOT NULL,
    name             VARCHAR(100) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    phone            VARCHAR(15),
    dob              DATE,
    enrollment_year  INT NOT NULL,
    password_hash    VARCHAR(255) NOT NULL,
    FOREIGN KEY (program_id) REFERENCES PROGRAM(program_id) ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 3. ACADEMIC_RECORD
-- ------------------------------------------------------------
CREATE TABLE ACADEMIC_RECORD (
    record_id       INT AUTO_INCREMENT PRIMARY KEY,
    student_id      INT NOT NULL,
    semester        INT NOT NULL,
    sgpa            DECIMAL(3,2) NOT NULL,
    backlog_count   INT DEFAULT 0,
    academic_year   INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 4. COMPANY
-- ------------------------------------------------------------
CREATE TABLE COMPANY (
    company_id      INT AUTO_INCREMENT PRIMARY KEY,
    company_name    VARCHAR(150) NOT NULL,
    industry        VARCHAR(100),
    website         VARCHAR(150),
    contact_email   VARCHAR(100) NOT NULL,
    contact_phone   VARCHAR(15)
);

-- ------------------------------------------------------------
-- 5. JOB
-- ------------------------------------------------------------
CREATE TABLE JOB (
    job_id                INT AUTO_INCREMENT PRIMARY KEY,
    company_id            INT NOT NULL,
    job_title             VARCHAR(150) NOT NULL,
    job_description       TEXT,
    package_lpa           DECIMAL(5,2) NOT NULL,
    job_type              ENUM('Full-time','Internship') NOT NULL,
    location              VARCHAR(100),
    positions_available   INT NOT NULL,
    posted_date           DATE NOT NULL,
    application_deadline  DATE NOT NULL,
    status                ENUM('Open','Closed') DEFAULT 'Open',
    FOREIGN KEY (company_id) REFERENCES COMPANY(company_id) ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 6. JOB_ELIGIBILITY
-- ------------------------------------------------------------
CREATE TABLE JOB_ELIGIBILITY (
    eligibility_id  INT AUTO_INCREMENT PRIMARY KEY,
    job_id          INT NOT NULL,
    program_id      INT NOT NULL,
    min_cgpa        DECIMAL(3,2) NOT NULL,
    max_backlogs    INT DEFAULT 0,
    FOREIGN KEY (job_id) REFERENCES JOB(job_id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES PROGRAM(program_id) ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 7. APPLICATION
-- ------------------------------------------------------------
CREATE TABLE APPLICATION (
    application_id     INT AUTO_INCREMENT PRIMARY KEY,
    student_id         INT NOT NULL,
    job_id             INT NOT NULL,
    application_date   DATE NOT NULL,
    status             ENUM('Applied','Shortlisted','Interviewed','Selected','Rejected') DEFAULT 'Applied',
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES JOB(job_id) ON DELETE CASCADE,
    UNIQUE (student_id, job_id)   -- a student cannot apply twice to the same job
);

-- ------------------------------------------------------------
-- 8. TEST_RESULT
-- ------------------------------------------------------------
CREATE TABLE TEST_RESULT (
    test_result_id   INT AUTO_INCREMENT PRIMARY KEY,
    application_id   INT NOT NULL,
    test_date        DATE NOT NULL,
    test_score       DECIMAL(5,2) NOT NULL,
    max_score        DECIMAL(5,2) NOT NULL,
    result_status    ENUM('Pass','Fail') NOT NULL,
    FOREIGN KEY (application_id) REFERENCES APPLICATION(application_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 9. INTERVIEW
-- ------------------------------------------------------------
CREATE TABLE INTERVIEW (
    interview_id       INT AUTO_INCREMENT PRIMARY KEY,
    application_id     INT NOT NULL,
    interview_date     DATE NOT NULL,
    interview_mode     ENUM('Online','Offline') NOT NULL,
    interviewer_name   VARCHAR(100),
    interview_status   ENUM('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled',
    feedback           TEXT,
    FOREIGN KEY (application_id) REFERENCES APPLICATION(application_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 10. OFFER
-- ------------------------------------------------------------
CREATE TABLE OFFER (
    offer_id              INT AUTO_INCREMENT PRIMARY KEY,
    application_id        INT NOT NULL UNIQUE,   -- one application gives at most one offer
    offer_date            DATE NOT NULL,
    package_offered_lpa   DECIMAL(5,2) NOT NULL,
    offer_status          ENUM('Pending','Accepted','Declined') DEFAULT 'Pending',
    joining_date          DATE,
    FOREIGN KEY (application_id) REFERENCES APPLICATION(application_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- Indexes (minimum 2 required by the course proforma)
-- These speed up the two most frequent lookups in our app:
-- logging in by email, and filtering applications by status
-- ------------------------------------------------------------
CREATE INDEX idx_student_email ON STUDENT(email);
CREATE INDEX idx_application_status ON APPLICATION(status);