# Group 10 - University Placement and Recruitment Management System
## Normalization
### Member 2 Deliverable - Phase IV

In this document we check our relational schema (from Relational_Schema.md)
against the normal forms we studied in class - 1NF, 2NF and 3NF. The goal of
normalization is to remove data redundancy and avoid update/insert/delete
anomalies.

---

## Quick recap of the normal forms (for our own understanding)

**1NF (First Normal Form):**
A table is in 1NF if every column holds only atomic (single, indivisible)
values, and there are no repeating groups or multi-valued columns. Every row
must be uniquely identifiable.

**2NF (Second Normal Form):**
A table is in 2NF if it is already in 1NF, and every non-key column depends
on the *whole* primary key, not just part of it. This problem (called partial
dependency) only happens when the primary key is made of more than one
column (a composite key).

**3NF (Third Normal Form):**
A table is in 3NF if it is already in 2NF, and no non-key column depends on
another non-key column (this is called a transitive dependency). Every
non-key column should depend directly on the primary key and nothing else.

---

## Step 1: Checking 1NF

Before we finalized the ER diagram, we noticed that a job could be open to
more than one branch (for example, CSE and IT both being eligible for the
same job posting, with different CGPA cutoffs). If we had stored this as one
column like `eligible_branches = "CSE, IT"` inside the JOB table, that column
would NOT be atomic - it would be a repeating group, which breaks 1NF.

That is exactly why we made a separate table called **JOB_ELIGIBILITY**,
with one row per job-per-eligible-program. This keeps every column atomic
and our design satisfies 1NF right from the start.

We checked all our other tables (STUDENT, COMPANY, APPLICATION, etc.) and
none of them store multiple values in a single column, and every table has a
primary key that uniquely identifies each row. So all 10 tables are in 1NF.

---

## Step 2: Checking 2NF

2NF problems (partial dependency) only happen when a table has a composite
primary key (a key made of two or more columns). In our design, **every
single table uses a single-column surrogate primary key** (like
`student_id`, `job_id`, `application_id`, etc. - all auto-incrementing
integers).

Because there is no composite key anywhere in our schema, there is no way
for a partial dependency to exist. So once a table is in 1NF, it is
automatically in 2NF too. All 10 tables satisfy 2NF.

(Note: We did think about whether APPLICATION should use a composite key of
`student_id + job_id` instead of a surrogate `application_id`, since that
combination is unique. But we chose to keep `application_id` as a simple
surrogate key and instead added a `UNIQUE(student_id, job_id)` constraint
separately. This keeps the table simpler for foreign key references from
TEST_RESULT, INTERVIEW and OFFER, which only need to point to one column.)

---

## Step 3: Checking 3NF (Functional Dependencies)

Here we list the functional dependencies (FD) for each table and check for
any transitive dependency (a non-key column depending on another non-key
column instead of directly on the primary key).

**PROGRAM**
FD: program_id -> program_name, department, duration_years
No transitive dependency found. In 3NF.

**STUDENT**
FD: student_id -> program_id, name, email, phone, dob, enrollment_year, password_hash
`program_id` is a foreign key, and none of the other columns depend on it -
they all depend directly on `student_id`. In 3NF.

**ACADEMIC_RECORD**
FD: record_id -> student_id, semester, sgpa, backlog_count, academic_year
No transitive dependency. In 3NF.

**COMPANY**
FD: company_id -> company_name, industry, website, contact_email, contact_phone
No transitive dependency. In 3NF.

**JOB**
FD: job_id -> company_id, job_title, job_description, package_lpa, job_type,
location, positions_available, posted_date, application_deadline, status
We checked if `location` might depend on `company_id` instead of `job_id`
(since a company could have one main office). But in our case a company can
post jobs at different locations, so `location` is job-specific, not
company-specific. No transitive dependency. In 3NF.

**JOB_ELIGIBILITY**
FD: eligibility_id -> job_id, program_id, min_cgpa, max_backlogs
No transitive dependency. In 3NF.

**APPLICATION**
FD: application_id -> student_id, job_id, application_date, status
No transitive dependency. In 3NF.

**TEST_RESULT**
FD: test_result_id -> application_id, test_date, test_score, max_score, result_status
No transitive dependency. In 3NF.

**INTERVIEW**
FD: interview_id -> application_id, interview_date, interview_mode,
interviewer_name, interview_status, feedback
No transitive dependency. In 3NF.

**OFFER**
FD: offer_id -> application_id, offer_date, package_offered_lpa, offer_status, joining_date
No transitive dependency. In 3NF.

---

## Conclusion

After checking all 10 tables step by step, our schema satisfies 1NF, 2NF and
3NF. We did not need to go up to BCNF because none of our tables have more
than one candidate key that overlaps in a way that would cause a BCNF
violation - all our tables have exactly one candidate key (the surrogate
primary key), except APPLICATION and OFFER which have one extra unique
constraint, and neither of those causes a BCNF problem either.

This means our design should not have update, insert or delete anomalies,
and is ready to be implemented as actual SQL tables by Member 3.