# Group 10 — University Placement and Recruitment Management System
## Relational Schema
### Member 2 Deliverable — Phase III (Logical Design)

This document converts the ER model (see `Requirement_Analysis_and_ER_Diagram.md`)
into a formal relational schema: every entity becomes a table with explicit
columns, data types, primary keys, foreign keys, and constraints. This is the
direct blueprint for `database/schema.sql`.

**Notation:** PK = Primary Key, FK = Foreign Key, NN = Not Null

---

## 1. PROGRAM

| Column | Data Type | Constraint |
|---|---|---|
| program_id | INT | PK, AUTO_INCREMENT |
| program_name | VARCHAR(100) | NOT NULL |
| department | VARCHAR(100) | NOT NULL |
| duration_years | INT | NOT NULL |

---

## 2. STUDENT

| Column | Data Type | Constraint |
|---|---|---|
| student_id | INT | PK, AUTO_INCREMENT |
| program_id | INT | FK -> PROGRAM(program_id), NOT NULL |
| name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(100) | UNIQUE, NOT NULL |
| phone | VARCHAR(15) | |
| dob | DATE | |
| enrollment_year | INT | NOT NULL |
| password_hash | VARCHAR(255) | NOT NULL |

---

## 3. ACADEMIC_RECORD

| Column | Data Type | Constraint |
|---|---|---|
| record_id | INT | PK, AUTO_INCREMENT |
| student_id | INT | FK -> STUDENT(student_id), NOT NULL |
| semester | INT | NOT NULL |
| sgpa | DECIMAL(3,2) | NOT NULL |
| backlog_count | INT | DEFAULT 0 |
| academic_year | INT | NOT NULL |

---

## 4. COMPANY

| Column | Data Type | Constraint |
|---|---|---|
| company_id | INT | PK, AUTO_INCREMENT |
| company_name | VARCHAR(150) | NOT NULL |
| industry | VARCHAR(100) | |
| website | VARCHAR(150) | |
| contact_email | VARCHAR(100) | NOT NULL |
| contact_phone | VARCHAR(15) | |

---

## 5. JOB

| Column | Data Type | Constraint |
|---|---|---|
| job_id | INT | PK, AUTO_INCREMENT |
| company_id | INT | FK -> COMPANY(company_id), NOT NULL |
| job_title | VARCHAR(150) | NOT NULL |
| job_description | TEXT | |
| package_lpa | DECIMAL(5,2) | NOT NULL |
| job_type | ENUM('Full-time','Internship') | NOT NULL |
| location | VARCHAR(100) | |
| positions_available | INT | NOT NULL |
| posted_date | DATE | NOT NULL |
| application_deadline | DATE | NOT NULL |
| status | ENUM('Open','Closed') | DEFAULT 'Open' |

---

## 6. JOB_ELIGIBILITY

| Column | Data Type | Constraint |
|---|---|---|
| eligibility_id | INT | PK, AUTO_INCREMENT |
| job_id | INT | FK -> JOB(job_id), NOT NULL |
| program_id | INT | FK -> PROGRAM(program_id), NOT NULL |
| min_cgpa | DECIMAL(3,2) | NOT NULL |
| max_backlogs | INT | DEFAULT 0 |

*Design note: kept separate from JOB so one job can define different CGPA/backlog
cutoffs per eligible branch (one row per job-program combination).*

---

## 7. APPLICATION

| Column | Data Type | Constraint |
|---|---|---|
| application_id | INT | PK, AUTO_INCREMENT |
| student_id | INT | FK -> STUDENT(student_id), NOT NULL |
| job_id | INT | FK -> JOB(job_id), NOT NULL |
| application_date | DATE | NOT NULL |
| status | ENUM('Applied','Shortlisted','Interviewed','Selected','Rejected') | DEFAULT 'Applied' |

**Additional constraint:** `UNIQUE (student_id, job_id)` — enforces the business
rule that a student cannot apply twice to the same job.

---

## 8. TEST_RESULT

| Column | Data Type | Constraint |
|---|---|---|
| test_result_id | INT | PK, AUTO_INCREMENT |
| application_id | INT | FK -> APPLICATION(application_id), NOT NULL |
| test_date | DATE | NOT NULL |
| test_score | DECIMAL(5,2) | NOT NULL |
| max_score | DECIMAL(5,2) | NOT NULL |
| result_status | ENUM('Pass','Fail') | NOT NULL |

---

## 9. INTERVIEW

| Column | Data Type | Constraint |
|---|---|---|
| interview_id | INT | PK, AUTO_INCREMENT |
| application_id | INT | FK -> APPLICATION(application_id), NOT NULL |
| interview_date | DATE | NOT NULL |
| interview_mode | ENUM('Online','Offline') | NOT NULL |
| interviewer_name | VARCHAR(100) | |
| interview_status | ENUM('Scheduled','Completed','Cancelled') | DEFAULT 'Scheduled' |
| feedback | TEXT | |

---

## 10. OFFER

| Column | Data Type | Constraint |
|---|---|---|
| offer_id | INT | PK, AUTO_INCREMENT |
| application_id | INT | FK -> APPLICATION(application_id), NOT NULL, UNIQUE |
| offer_date | DATE | NOT NULL |
| package_offered_lpa | DECIMAL(5,2) | NOT NULL |
| offer_status | ENUM('Pending','Accepted','Declined') | DEFAULT 'Pending' |
| joining_date | DATE | |

*Note: `application_id` is UNIQUE here because one application can result in
at most one offer.*

---

## Referential Integrity Summary

| Child Table | Foreign Key | References | On Delete |
|---|---|---|---|
| STUDENT | program_id | PROGRAM(program_id) | RESTRICT |
| ACADEMIC_RECORD | student_id | STUDENT(student_id) | CASCADE |
| JOB | company_id | COMPANY(company_id) | RESTRICT |
| JOB_ELIGIBILITY | job_id | JOB(job_id) | CASCADE |
| JOB_ELIGIBILITY | program_id | PROGRAM(program_id) | RESTRICT |
| APPLICATION | student_id | STUDENT(student_id) | CASCADE |
| APPLICATION | job_id | JOB(job_id) | CASCADE |
| TEST_RESULT | application_id | APPLICATION(application_id) | CASCADE |
| INTERVIEW | application_id | APPLICATION(application_id) | CASCADE |
| OFFER | application_id | APPLICATION(application_id) | CASCADE |

*RESTRICT is used where deleting the parent (e.g., a PROGRAM or COMPANY) should
not silently wipe out unrelated records; CASCADE is used where child records
have no meaning without the parent (e.g., an ACADEMIC_RECORD with no STUDENT).*

---

## Handoff

- **Member 3** uses this document directly to write `database/schema.sql`
  (CREATE TABLE statements matching these exact columns/types/constraints).
- **This schema also feeds `Data_Dictionary.md` and `Normalization.md`**,
  the next two files in this Phase.