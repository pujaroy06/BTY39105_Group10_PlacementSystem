-- ============================================================
-- Group 10: University Placement and Recruitment Management System
-- File: procedures.sql
-- Purpose: Stored procedures and function implementing the
--          "Advanced DBMS Component" required for our project -
--          automatic student eligibility checking.
-- Member 4 Deliverable - Phase VII (Database Programming)
-- ============================================================

USE placement_system;

DELIMITER $$

-- ------------------------------------------------------------
-- FUNCTION: fn_get_student_cgpa
-- Calculates a student's cumulative CGPA as the average SGPA
-- across all their semester records. Used by the eligibility
-- procedure below instead of repeating this calculation there.
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_get_student_cgpa$$
CREATE FUNCTION fn_get_student_cgpa(p_student_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_cgpa DECIMAL(3,2);
    SELECT AVG(sgpa) INTO v_cgpa
    FROM ACADEMIC_RECORD
    WHERE student_id = p_student_id;
    RETURN v_cgpa;
END$$

-- ------------------------------------------------------------
-- PROCEDURE 1: sp_check_eligibility
-- The core "Advanced DBMS Component" for Group 10.
-- Given a student and a job, checks:
--   1. Is the job open to this student's program at all?
--   2. Is the job still Open and before its deadline?
--   3. Does the student's CGPA meet the minimum?
--   4. Are the student's backlogs within the allowed limit?
-- Returns TRUE/FALSE plus a human-readable message explaining why.
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_check_eligibility$$
CREATE PROCEDURE sp_check_eligibility(
    IN p_student_id INT,
    IN p_job_id INT,
    OUT p_is_eligible BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_program_id INT;
    DECLARE v_cgpa DECIMAL(3,2);
    DECLARE v_backlogs INT;
    DECLARE v_min_cgpa DECIMAL(3,2);
    DECLARE v_max_backlogs INT;
    DECLARE v_job_status VARCHAR(20);
    DECLARE v_deadline DATE;

    -- find the student's program
    SELECT program_id INTO v_program_id
    FROM STUDENT WHERE student_id = p_student_id;

    -- overall CGPA using the function above
    SET v_cgpa = fn_get_student_cgpa(p_student_id);

    -- most recent semester's backlog count
    SELECT backlog_count INTO v_backlogs
    FROM ACADEMIC_RECORD
    WHERE student_id = p_student_id
    ORDER BY semester DESC
    LIMIT 1;

    -- job's current status and deadline
    SELECT status, application_deadline INTO v_job_status, v_deadline
    FROM JOB WHERE job_id = p_job_id;

    -- eligibility rule for this job and this student's program
    SELECT min_cgpa, max_backlogs INTO v_min_cgpa, v_max_backlogs
    FROM JOB_ELIGIBILITY
    WHERE job_id = p_job_id AND program_id = v_program_id
    LIMIT 1;

    IF v_min_cgpa IS NULL THEN
        SET p_is_eligible = FALSE;
        SET p_message = 'This job is not open to your program.';
    ELSEIF v_job_status <> 'Open' THEN
        SET p_is_eligible = FALSE;
        SET p_message = 'This job is currently closed.';
    ELSEIF CURDATE() > v_deadline THEN
        SET p_is_eligible = FALSE;
        SET p_message = 'The application deadline has passed.';
    ELSEIF v_cgpa < v_min_cgpa THEN
        SET p_is_eligible = FALSE;
        SET p_message = CONCAT('CGPA too low. Required: ', v_min_cgpa, ', Yours: ', v_cgpa);
    ELSEIF v_backlogs > v_max_backlogs THEN
        SET p_is_eligible = FALSE;
        SET p_message = CONCAT('Too many backlogs. Allowed: ', v_max_backlogs, ', Yours: ', v_backlogs);
    ELSE
        SET p_is_eligible = TRUE;
        SET p_message = 'Eligible to apply.';
    END IF;
END$$

-- ------------------------------------------------------------
-- PROCEDURE 2: sp_submit_application
-- Called by the Python backend when a student clicks "Apply".
-- First checks for a duplicate application, then calls
-- sp_check_eligibility above before allowing the INSERT.
-- This keeps the business rule enforcement inside the database,
-- not just in the Python code.
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_submit_application$$
CREATE PROCEDURE sp_submit_application(
    IN p_student_id INT,
    IN p_job_id INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_is_eligible BOOLEAN;
    DECLARE v_eligibility_message VARCHAR(255);
    DECLARE v_already_applied INT;

    SELECT COUNT(*) INTO v_already_applied
    FROM APPLICATION
    WHERE student_id = p_student_id AND job_id = p_job_id;

    IF v_already_applied > 0 THEN
        SET p_result_message = 'You have already applied to this job.';
    ELSE
        CALL sp_check_eligibility(p_student_id, p_job_id, v_is_eligible, v_eligibility_message);

        IF v_is_eligible THEN
            INSERT INTO APPLICATION (student_id, job_id, application_date, status)
            VALUES (p_student_id, p_job_id, CURDATE(), 'Applied');
            SET p_result_message = 'Application submitted successfully.';
        ELSE
            SET p_result_message = v_eligibility_message;
        END IF;
    END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- HOW TO TEST (uncomment and run manually)
-- ------------------------------------------------------------
-- CALL sp_check_eligibility(1, 1, @elig, @msg);
-- SELECT @elig AS is_eligible, @msg AS message;

-- CALL sp_submit_application(9, 3, @res);
-- SELECT @res AS result;