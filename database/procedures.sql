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

DELIMITER $$

-- ------------------------------------------------------------
-- PROCEDURE 3: sp_generate_offer
-- TRANSACTION DEMONSTRATION (Section 5 requirement: minimum 1)
-- Wraps two related writes - inserting the OFFER row and
-- updating the APPLICATION's status - inside one atomic
-- transaction. If anything fails partway (for example, trying
-- to generate a second offer for the same application, which
-- violates the UNIQUE constraint on OFFER.application_id), the
-- EXIT HANDLER rolls back BOTH writes, so the data never ends
-- up half-updated.
-- (Note: trg_after_offer_insert from triggers.sql would also
-- update the application status automatically. The explicit
-- UPDATE here is kept so the transaction's multi-step, all-or-
-- nothing nature is clearly visible for demonstration purposes.)
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_generate_offer$$
CREATE PROCEDURE sp_generate_offer(
    IN p_application_id INT,
    IN p_package DECIMAL(5,2),
    IN p_joining_date DATE,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_app_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_message = 'Transaction failed and was rolled back (an offer may already exist for this application).';
    END;

    START TRANSACTION;

    SELECT status INTO v_app_status
    FROM APPLICATION
    WHERE application_id = p_application_id
    FOR UPDATE;

    IF v_app_status IS NULL THEN
        SET p_result_message = 'Application not found.';
        ROLLBACK;
    ELSEIF v_app_status = 'Rejected' THEN
        SET p_result_message = 'Cannot generate an offer for a rejected application.';
        ROLLBACK;
    ELSE
        INSERT INTO OFFER (application_id, offer_date, package_offered_lpa, offer_status, joining_date)
        VALUES (p_application_id, CURDATE(), p_package, 'Pending', p_joining_date);

        UPDATE APPLICATION
        SET status = 'Selected'
        WHERE application_id = p_application_id;

        COMMIT;
        SET p_result_message = 'Offer generated successfully and application marked Selected.';
    END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- HOW TO TEST
-- ------------------------------------------------------------
-- Success case: application_id 22 has no offer yet
-- CALL sp_generate_offer(22, 4.10, '2026-08-15', @res);
-- SELECT @res;

-- Rollback case: application_id 2 ALREADY has an offer (see insert_data.sql)
-- so this second attempt violates the UNIQUE constraint and rolls back
-- CALL sp_generate_offer(2, 5.00, '2026-08-20', @res);
-- SELECT @res;
-- Expected: 'Transaction failed and was rolled back...'
-- and OFFER table should NOT contain a second row for application_id 2