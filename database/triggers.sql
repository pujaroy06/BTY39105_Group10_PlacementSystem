-- ============================================================
-- Group 10: University Placement and Recruitment Management System
-- File: triggers.sql
-- Purpose: Triggers that enforce business rules and keep related
--          tables automatically in sync.
-- Member 4 Deliverable - Phase VII (Database Programming)
-- ============================================================

USE placement_system;

DELIMITER $$

-- ------------------------------------------------------------
-- TRIGGER 1: trg_before_application_insert
-- Fires BEFORE a new row is inserted into APPLICATION.
-- Acts as a safety net at the database level: even if someone
-- tries to insert an application directly (bypassing our
-- sp_submit_application procedure), the database itself refuses
-- to accept an application for a closed job or a job whose
-- deadline has already passed.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_before_application_insert$$
CREATE TRIGGER trg_before_application_insert
BEFORE INSERT ON APPLICATION
FOR EACH ROW
BEGIN
    DECLARE v_deadline DATE;
    DECLARE v_status VARCHAR(20);

    SELECT application_deadline, status INTO v_deadline, v_status
    FROM JOB WHERE job_id = NEW.job_id;

    IF v_status <> 'Open' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot apply: this job is closed.';
    ELSEIF NEW.application_date > v_deadline THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot apply: the application deadline has passed.';
    END IF;
END$$

-- ------------------------------------------------------------
-- TRIGGER 2: trg_after_offer_insert
-- Fires AFTER a new row is inserted into OFFER.
-- Automatically updates the linked APPLICATION's status to
-- 'Selected', so the admin never has to remember to update two
-- tables by hand when an offer is created.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_after_offer_insert$$
CREATE TRIGGER trg_after_offer_insert
AFTER INSERT ON OFFER
FOR EACH ROW
BEGIN
    UPDATE APPLICATION
    SET status = 'Selected'
    WHERE application_id = NEW.application_id
      AND status <> 'Selected';
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- HOW TO TEST (uncomment and run manually)
-- ------------------------------------------------------------
-- Test Trigger 1: try applying after job 2's deadline (2026-08-10) has passed
-- INSERT INTO APPLICATION (student_id, job_id, application_date, status)
-- VALUES (17, 2, '2026-09-01', 'Applied');
-- Expected: error "Cannot apply: the application deadline has passed."

-- Test Trigger 2: insert a fresh offer for an application still marked 'Applied'
-- INSERT INTO OFFER (application_id, offer_date, package_offered_lpa, offer_status)
-- VALUES (1, '2026-08-01', 3.60, 'Pending');
-- SELECT status FROM APPLICATION WHERE application_id = 1;
-- Expected: status is now 'Selected' automatically