# Group 10 — University Placement and Recruitment Management System
## Data Dictionary
### Member 2 Deliverable — Phase III (Logical Design)

This document lists every column across all 10 tables with its data type,
nullability, and a plain-language description. Use this as the quick-reference
companion to `Relational_Schema.md`.

---

## PROGRAM

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| program_id | INT | No | Unique identifier for an academic program |
| program_name | VARCHAR(100) | No | Name of the program (e.g., B.Tech CSE) |
| department | VARCHAR(100) | No | Department offering the program |
| duration_years | INT | No | Length of the program in years |

---

## STUDENT

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| student_id | INT | No | Unique identifier for a student |
| program_id | INT | No | Program the student is enrolled in (FK) |
| name | VARCHAR(100) | No | Full name of the student |
| email | VARCHAR(100) | No | Login email, must be unique |
| phone | VARCHAR(15) | Yes | Contact phone number |
| dob | DATE | Yes | Date of birth |
| enrollment_year | INT | No | Year the student joined the program |
| password_hash | VARCHAR(255) | No | Hashed password (never stored in plain text) |

---

## ACADEMIC_RECORD

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| record_id | INT | No | Unique identifier for one semester's record |
| student_id | INT | No | Student this record belongs to (FK) |
| semester | INT | No | Semester number (1-8) |
| sgpa | DECIMAL(3,2) | No | Semester grade point average |
| backlog_count | INT | No (default 0) | Number of backlog subjects that semester |
| academic_year | INT | No | Calendar year the semester occurred |

---

## COMPANY

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| company_id | INT | No | Unique identifier for a recruiting company |
| company_name | VARCHAR(150) | No | Name of the company |
| industry | VARCHAR(100) | Yes | Industry sector (IT, Finance, etc.) |
| website | VARCHAR(150) | Yes | Company website URL |
| contact_email | VARCHAR(100) | No | HR/recruiter contact email |
| contact_phone | VARCHAR(15) | Yes | HR/recruiter contact phone |

---

## JOB

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| job_id | INT | No | Unique identifier for a job posting |
| company_id | INT | No | Company that posted the job (FK) |
| job_title | VARCHAR(150) | No | Title of the position |
| job_description | TEXT | Yes | Detailed job description |
| package_lpa | DECIMAL(5,2) | No | Offered package in Lakhs Per Annum |
| job_type | ENUM | No | Full-time or Internship |
| location | VARCHAR(100) | Yes | Job location |
| positions_available | INT | No | Number of open positions |
| posted_date | DATE | No | Date the job was posted |
| application_deadline | DATE | No | Last date to apply |
| status | ENUM | No (default 'Open') | Open or Closed |

---

## JOB_ELIGIBILITY

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| eligibility_id | INT | No | Unique identifier for one eligibility rule |
| job_id | INT | No | Job this rule applies to (FK) |
| program_id | INT | No | Program eligible under this rule (FK) |
| min_cgpa | DECIMAL(3,2) | No | Minimum CGPA required |
| max_backlogs | INT | No (default 0) | Maximum allowed backlogs |

---

## APPLICATION

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| application_id | INT | No | Unique identifier for an application |
| student_id | INT | No | Student who applied (FK) |
| job_id | INT | No | Job applied to (FK) |
| application_date | DATE | No | Date the application was submitted |
| status | ENUM | No (default 'Applied') | Applied / Shortlisted / Interviewed / Selected / Rejected |

---

## TEST_RESULT

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| test_result_id | INT | No | Unique identifier for a test result |
| application_id | INT | No | Application this test belongs to (FK) |
| test_date | DATE | No | Date the test was conducted |
| test_score | DECIMAL(5,2) | No | Score obtained |
| max_score | DECIMAL(5,2) | No | Maximum possible score |
| result_status | ENUM | No | Pass or Fail |

---

## INTERVIEW

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| interview_id | INT | No | Unique identifier for an interview round |
| application_id | INT | No | Application this interview belongs to (FK) |
| interview_date | DATE | No | Date of the interview |
| interview_mode | ENUM | No | Online or Offline |
| interviewer_name | VARCHAR(100) | Yes | Name of the interviewer |
| interview_status | ENUM | No (default 'Scheduled') | Scheduled / Completed / Cancelled |
| feedback | TEXT | Yes | Interviewer's remarks |

---

## OFFER

| Column | Data Type | Nullable | Description |
|---|---|---|---|
| offer_id | INT | No | Unique identifier for an offer |
| application_id | INT | No | Application this offer resulted from (FK, unique) |
| offer_date | DATE | No | Date the offer was extended |
| package_offered_lpa | DECIMAL(5,2) | No | Final offered package in LPA |
| offer_status | ENUM | No (default 'Pending') | Pending / Accepted / Declined |
| joining_date | DATE | Yes | Expected joining date |