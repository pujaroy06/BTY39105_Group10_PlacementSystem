-- ============================================================
-- Group 10: University Placement and Recruitment Management System
-- File: insert_data.sql
-- Purpose: Populates all 10 tables with realistic sample data
--          (172 rows total, well above the 100+ recommended minimum)
-- Member 3 Deliverable - Phase V (Database Development)
-- Run schema.sql FIRST, then run this file.
-- ============================================================

USE placement_system;

-- ------------------------------------------------------------
-- 1. PROGRAM (4 rows)
-- ------------------------------------------------------------
INSERT INTO PROGRAM (program_id, program_name, department, duration_years) VALUES
(1, 'B.Tech CSE', 'Computer Science and Engineering', 4),
(2, 'B.Tech CSE (AI & ML)', 'Computer Science and Engineering', 4),
(3, 'B.Tech IT', 'Information Technology', 4),
(4, 'B.Tech ECE', 'Electronics and Communication Engineering', 4);

-- ------------------------------------------------------------
-- 2. STUDENT (20 rows)
-- password_hash values below are placeholders only. In the real
-- Flask app these will be generated using werkzeug.security's
-- generate_password_hash() function, never stored as plain text.
-- ------------------------------------------------------------
INSERT INTO STUDENT (student_id, program_id, name, email, phone, dob, enrollment_year, password_hash) VALUES
(1, 1, 'Rahul Sharma', 'rahul.sharma22@brainware.edu.in', '9830011001', '2004-03-12', 2022, 'hashed_pw_001'),
(2, 2, 'Priya Singh', 'priya.singh22@brainware.edu.in', '9830011002', '2004-05-21', 2022, 'hashed_pw_002'),
(3, 3, 'Amit Kumar', 'amit.kumar22@brainware.edu.in', '9830011003', '2003-11-09', 2022, 'hashed_pw_003'),
(4, 4, 'Sneha Roy', 'sneha.roy22@brainware.edu.in', '9830011004', '2004-01-15', 2022, 'hashed_pw_004'),
(5, 1, 'Arjun Das', 'arjun.das22@brainware.edu.in', '9830011005', '2004-07-02', 2022, 'hashed_pw_005'),
(6, 2, 'Megha Paul', 'megha.paul22@brainware.edu.in', '9830011006', '2003-09-18', 2022, 'hashed_pw_006'),
(7, 3, 'Vikram Yadav', 'vikram.yadav22@brainware.edu.in', '9830011007', '2004-02-27', 2022, 'hashed_pw_007'),
(8, 4, 'Anjali Gupta', 'anjali.gupta22@brainware.edu.in', '9830011008', '2004-06-30', 2022, 'hashed_pw_008'),
(9, 1, 'Rohan Mehta', 'rohan.mehta22@brainware.edu.in', '9830011009', '2003-12-05', 2022, 'hashed_pw_009'),
(10, 2, 'Kavita Nair', 'kavita.nair22@brainware.edu.in', '9830011010', '2004-04-14', 2022, 'hashed_pw_010'),
(11, 3, 'Suresh Reddy', 'suresh.reddy22@brainware.edu.in', '9830011011', '2004-08-22', 2022, 'hashed_pw_011'),
(12, 4, 'Pooja Iyer', 'pooja.iyer22@brainware.edu.in', '9830011012', '2003-10-11', 2022, 'hashed_pw_012'),
(13, 1, 'Karan Malhotra', 'karan.malhotra22@brainware.edu.in', '9830011013', '2004-01-29', 2022, 'hashed_pw_013'),
(14, 2, 'Neha Joshi', 'neha.joshi22@brainware.edu.in', '9830011014', '2004-03-03', 2022, 'hashed_pw_014'),
(15, 3, 'Aditya Verma', 'aditya.verma22@brainware.edu.in', '9830011015', '2003-07-19', 2022, 'hashed_pw_015'),
(16, 4, 'Riya Chatterjee', 'riya.chatterjee22@brainware.edu.in', '9830011016', '2004-05-08', 2022, 'hashed_pw_016'),
(17, 1, 'Manish Tiwari', 'manish.tiwari22@brainware.edu.in', '9830011017', '2004-09-25', 2022, 'hashed_pw_017'),
(18, 2, 'Divya Pillai', 'divya.pillai22@brainware.edu.in', '9830011018', '2003-11-30', 2022, 'hashed_pw_018'),
(19, 3, 'Sandeep Rao', 'sandeep.rao22@brainware.edu.in', '9830011019', '2004-02-14', 2022, 'hashed_pw_019'),
(20, 4, 'Isha Bhatt', 'isha.bhatt22@brainware.edu.in', '9830011020', '2004-06-06', 2022, 'hashed_pw_020');

-- ------------------------------------------------------------
-- 3. ACADEMIC_RECORD (40 rows - 2 semesters per student)
-- ------------------------------------------------------------
INSERT INTO ACADEMIC_RECORD (record_id, student_id, semester, sgpa, backlog_count, academic_year) VALUES
(1, 1, 5, 8.20, 0, 2024), (2, 1, 6, 8.40, 0, 2025),
(3, 2, 5, 7.80, 0, 2024), (4, 2, 6, 8.00, 0, 2025),
(5, 3, 5, 6.50, 1, 2024), (6, 3, 6, 6.90, 0, 2025),
(7, 4, 5, 7.20, 0, 2024), (8, 4, 6, 7.50, 0, 2025),
(9, 5, 5, 8.90, 0, 2024), (10, 5, 6, 9.10, 0, 2025),
(11, 6, 5, 7.00, 0, 2024), (12, 6, 6, 7.30, 0, 2025),
(13, 7, 5, 6.20, 1, 2024), (14, 7, 6, 6.60, 1, 2025),
(15, 8, 5, 8.10, 0, 2024), (16, 8, 6, 8.30, 0, 2025),
(17, 9, 5, 7.60, 0, 2024), (18, 9, 6, 7.80, 0, 2025),
(19, 10, 5, 8.50, 0, 2024), (20, 10, 6, 8.70, 0, 2025),
(21, 11, 5, 6.80, 0, 2024), (22, 11, 6, 7.00, 0, 2025),
(23, 12, 5, 7.90, 0, 2024), (24, 12, 6, 8.10, 0, 2025),
(25, 13, 5, 9.20, 0, 2024), (26, 13, 6, 9.40, 0, 2025),
(27, 14, 5, 7.40, 0, 2024), (28, 14, 6, 7.60, 0, 2025),
(29, 15, 5, 6.30, 1, 2024), (30, 15, 6, 6.50, 1, 2025),
(31, 16, 5, 8.60, 0, 2024), (32, 16, 6, 8.80, 0, 2025),
(33, 17, 5, 7.10, 0, 2024), (34, 17, 6, 7.35, 0, 2025),
(35, 18, 5, 8.00, 0, 2024), (36, 18, 6, 8.20, 0, 2025),
(37, 19, 5, 6.70, 0, 2024), (38, 19, 6, 6.95, 0, 2025),
(39, 20, 5, 7.75, 0, 2024), (40, 20, 6, 7.95, 0, 2025);

-- ------------------------------------------------------------
-- 4. COMPANY (8 rows)
-- ------------------------------------------------------------
INSERT INTO COMPANY (company_id, company_name, industry, website, contact_email, contact_phone) VALUES
(1, 'TCS', 'IT Services', 'www.tcs.com', 'hr.tcs@tcs.com', '03322220001'),
(2, 'Infosys', 'IT Services', 'www.infosys.com', 'careers@infosys.com', '03322220002'),
(3, 'Wipro', 'IT Services', 'www.wipro.com', 'careers@wipro.com', '03322220003'),
(4, 'Accenture', 'Consulting and IT Services', 'www.accenture.com', 'careers@accenture.com', '03322220004'),
(5, 'Cognizant', 'IT Services', 'www.cognizant.com', 'careers@cognizant.com', '03322220005'),
(6, 'Capgemini', 'IT Consulting', 'www.capgemini.com', 'careers@capgemini.com', '03322220006'),
(7, 'HCL Technologies', 'IT Services', 'www.hcltech.com', 'careers@hcltech.com', '03322220007'),
(8, 'Tech Mahindra', 'IT and Telecom', 'www.techmahindra.com', 'careers@techmahindra.com', '03322220008');

-- ------------------------------------------------------------
-- 5. JOB (15 rows)
-- ------------------------------------------------------------
INSERT INTO JOB (job_id, company_id, job_title, job_description, package_lpa, job_type, location, positions_available, posted_date, application_deadline, status) VALUES
(1, 1, 'Systems Engineer', 'Entry level software role involving coding, testing and support.', 3.60, 'Full-time', 'Kolkata', 15, '2026-07-01', '2026-08-15', 'Open'),
(2, 1, 'Digital Trainee Engineer', 'Trainee role in digital transformation projects.', 4.00, 'Full-time', 'Kolkata', 10, '2026-07-02', '2026-08-10', 'Closed'),
(3, 2, 'Systems Engineer', 'Entry level engineering role with training program.', 3.60, 'Full-time', 'Bangalore', 20, '2026-07-01', '2026-08-15', 'Open'),
(4, 2, 'Power Programmer', 'Advanced coding role for high performers.', 6.50, 'Full-time', 'Pune', 8, '2026-07-03', '2026-08-20', 'Open'),
(5, 3, 'Project Engineer', 'Entry level role supporting client projects.', 3.50, 'Full-time', 'Kolkata', 12, '2026-07-02', '2026-08-15', 'Open'),
(6, 4, 'Associate Software Engineer', 'Software development role in agile teams.', 4.50, 'Full-time', 'Bangalore', 10, '2026-07-04', '2026-08-18', 'Open'),
(7, 4, 'Data Analyst Intern', 'Internship analyzing business data and reports.', 2.40, 'Internship', 'Bangalore', 5, '2026-07-04', '2026-08-12', 'Open'),
(8, 5, 'Programmer Analyst', 'Entry level developer role with mentorship.', 4.00, 'Full-time', 'Kolkata', 15, '2026-07-05', '2026-08-20', 'Open'),
(9, 6, 'Software Developer', 'Full stack development role for client products.', 4.25, 'Full-time', 'Mumbai', 10, '2026-07-05', '2026-08-22', 'Open'),
(10, 7, 'Graduate Engineer Trainee', 'Trainee program leading to full time role.', 3.75, 'Full-time', 'Noida', 12, '2026-07-06', '2026-08-20', 'Open'),
(11, 8, 'Associate Software Engineer', 'Entry level engineering role in telecom projects.', 3.80, 'Full-time', 'Pune', 10, '2026-07-06', '2026-08-18', 'Open'),
(12, 1, 'Business Analyst', 'Analytical role bridging business and technology teams.', 5.50, 'Full-time', 'Kolkata', 5, '2026-07-07', '2026-08-25', 'Open'),
(13, 2, 'Research Intern', 'Internship supporting applied research projects.', 2.00, 'Internship', 'Bangalore', 4, '2026-07-07', '2026-08-15', 'Open'),
(14, 3, 'Cloud Engineer', 'Role focused on cloud infrastructure and deployment.', 5.00, 'Full-time', 'Hyderabad', 6, '2026-07-08', '2026-08-25', 'Open'),
(15, 4, 'Full Stack Developer', 'End to end web application development role.', 6.00, 'Full-time', 'Bangalore', 8, '2026-07-08', '2026-08-28', 'Closed');

-- ------------------------------------------------------------
-- 6. JOB_ELIGIBILITY (20 rows)
-- ------------------------------------------------------------
INSERT INTO JOB_ELIGIBILITY (eligibility_id, job_id, program_id, min_cgpa, max_backlogs) VALUES
(1, 1, 1, 6.00, 1),
(2, 1, 3, 6.00, 1),
(3, 2, 1, 6.50, 0),
(4, 3, 1, 6.00, 1),
(5, 3, 2, 6.00, 1),
(6, 3, 3, 6.00, 1),
(7, 4, 1, 7.50, 0),
(8, 5, 1, 6.00, 1),
(9, 5, 4, 6.00, 1),
(10, 6, 2, 7.00, 0),
(11, 7, 2, 6.50, 1),
(12, 8, 3, 6.00, 1),
(13, 9, 1, 6.50, 0),
(14, 9, 3, 6.50, 0),
(15, 10, 4, 6.00, 1),
(16, 11, 1, 6.00, 1),
(17, 12, 1, 7.00, 0),
(18, 13, 2, 6.50, 1),
(19, 14, 4, 7.00, 0),
(20, 15, 2, 7.50, 0);

-- ------------------------------------------------------------
-- 7. APPLICATION (25 rows)
-- ------------------------------------------------------------
INSERT INTO APPLICATION (application_id, student_id, job_id, application_date, status) VALUES
(1, 1, 1, '2026-07-05', 'Applied'),
(2, 1, 12, '2026-07-06', 'Selected'),
(3, 2, 6, '2026-07-05', 'Applied'),
(4, 2, 13, '2026-07-07', 'Selected'),
(5, 3, 3, '2026-07-05', 'Shortlisted'),
(6, 3, 8, '2026-07-10', 'Selected'),
(7, 4, 5, '2026-07-06', 'Applied'),
(8, 4, 10, '2026-07-09', 'Selected'),
(9, 5, 1, '2026-07-06', 'Applied'),
(10, 5, 11, '2026-07-08', 'Selected'),
(11, 6, 7, '2026-07-07', 'Applied'),
(12, 6, 15, '2026-07-09', 'Rejected'),
(13, 7, 3, '2026-07-07', 'Applied'),
(14, 7, 9, '2026-07-11', 'Selected'),
(15, 8, 5, '2026-07-08', 'Selected'),
(16, 8, 14, '2026-07-12', 'Selected'),
(17, 9, 2, '2026-07-08', 'Applied'),
(18, 9, 4, '2026-07-10', 'Rejected'),
(19, 10, 6, '2026-07-09', 'Selected'),
(20, 11, 8, '2026-07-09', 'Applied'),
(21, 11, 9, '2026-07-13', 'Selected'),
(22, 12, 10, '2026-07-10', 'Applied'),
(23, 13, 11, '2026-07-10', 'Applied'),
(24, 14, 7, '2026-07-11', 'Shortlisted'),
(25, 15, 3, '2026-07-11', 'Rejected');

-- ------------------------------------------------------------
-- 8. TEST_RESULT (15 rows)
-- ------------------------------------------------------------
INSERT INTO TEST_RESULT (test_result_id, application_id, test_date, test_score, max_score, result_status) VALUES
(1, 2, '2026-07-07', 78.00, 100.00, 'Pass'),
(2, 4, '2026-07-08', 65.00, 100.00, 'Pass'),
(3, 5, '2026-07-06', 82.00, 100.00, 'Pass'),
(4, 6, '2026-07-08', 90.00, 100.00, 'Pass'),
(5, 8, '2026-07-10', 55.00, 100.00, 'Fail'),
(6, 10, '2026-07-09', 74.00, 100.00, 'Pass'),
(7, 12, '2026-07-10', 40.00, 100.00, 'Fail'),
(8, 14, '2026-07-12', 88.00, 100.00, 'Pass'),
(9, 15, '2026-07-09', 70.00, 100.00, 'Pass'),
(10, 16, '2026-07-11', 92.00, 100.00, 'Pass'),
(11, 18, '2026-07-11', 48.00, 100.00, 'Fail'),
(12, 19, '2026-07-10', 76.00, 100.00, 'Pass'),
(13, 21, '2026-07-12', 85.00, 100.00, 'Pass'),
(14, 24, '2026-07-12', 69.00, 100.00, 'Pass'),
(15, 25, '2026-07-12', 38.00, 100.00, 'Fail');

-- ------------------------------------------------------------
-- 9. INTERVIEW (15 rows)
-- ------------------------------------------------------------
INSERT INTO INTERVIEW (interview_id, application_id, interview_date, interview_mode, interviewer_name, interview_status, feedback) VALUES
(1, 2, '2026-07-09', 'Online', 'Mr. Sen', 'Completed', 'Good communication skills'),
(2, 4, '2026-07-10', 'Offline', 'Ms. Roy', 'Completed', 'Average technical knowledge'),
(3, 5, '2026-07-08', 'Online', 'Mr. Ghosh', 'Completed', 'Strong DBMS concepts'),
(4, 6, '2026-07-10', 'Offline', 'Ms. Banerjee', 'Completed', 'Excellent problem solving'),
(5, 8, '2026-07-12', 'Online', 'Mr. Iyer', 'Completed', 'Needs improvement in coding'),
(6, 10, '2026-07-11', 'Offline', 'Ms. Nair', 'Completed', 'Good aptitude'),
(7, 12, '2026-07-12', 'Online', 'Mr. Rao', 'Completed', 'Weak in fundamentals'),
(8, 14, '2026-07-14', 'Offline', 'Ms. Kapoor', 'Completed', 'Very confident candidate'),
(9, 15, '2026-07-11', 'Online', 'Mr. Chatterjee', 'Completed', 'Satisfactory performance'),
(10, 16, '2026-07-13', 'Offline', 'Ms. Sinha', 'Completed', 'Outstanding technical skills'),
(11, 18, '2026-07-13', 'Online', 'Mr. Dutta', 'Completed', 'Below expectations'),
(12, 19, '2026-07-12', 'Offline', 'Ms. Basu', 'Completed', 'Good communication'),
(13, 21, '2026-07-14', 'Online', 'Mr. Sarkar', 'Completed', 'Excellent coding round'),
(14, 24, '2026-07-14', 'Offline', 'Ms. Chakraborty', 'Completed', 'Decent performance'),
(15, 25, '2026-07-14', 'Online', 'Mr. Bose', 'Completed', 'Not up to the mark');

-- ------------------------------------------------------------
-- 10. OFFER (10 rows)
-- ------------------------------------------------------------
INSERT INTO OFFER (offer_id, application_id, offer_date, package_offered_lpa, offer_status, joining_date) VALUES
(1, 2, '2026-07-15', 5.50, 'Accepted', '2026-08-01'),
(2, 4, '2026-07-16', 2.00, 'Pending', NULL),
(3, 6, '2026-07-17', 4.00, 'Accepted', '2026-08-05'),
(4, 8, '2026-07-18', 3.75, 'Declined', NULL),
(5, 10, '2026-07-18', 3.80, 'Accepted', '2026-08-03'),
(6, 14, '2026-07-19', 4.25, 'Pending', NULL),
(7, 15, '2026-07-19', 3.50, 'Accepted', '2026-08-04'),
(8, 16, '2026-07-20', 5.00, 'Pending', NULL),
(9, 19, '2026-07-20', 4.50, 'Accepted', '2026-08-06'),
(10, 21, '2026-07-21', 4.25, 'Accepted', '2026-08-07');