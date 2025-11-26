-- Sequence for Audit Log IDs (Used by the logging trigger)
CREATE SEQUENCE access_violations_seq START WITH 1 INCREMENT BY 1;
/

-- Table to be protected (Target Data)
CREATE TABLE StudentData (
    student_id NUMBER PRIMARY KEY,
    student_name VARCHAR2(100),
    student_data VARCHAR2(100),
    last_modified DATE DEFAULT SYSDATE
);
/

-- Table for logging violations (Audit Log)
CREATE TABLE AccessViolations (
    log_id NUMBER PRIMARY KEY,
    user_name VARCHAR2(50),
    attempt_date DATE,
    action_attempted VARCHAR2(10),
    violation_reason VARCHAR2(255)
);
/

-- Insert initial dummy data
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (1, 'James Brown', 'Allowed to graduate');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (2, 'Alice Johnson', 'Enrolled in 2023');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (3, 'Robert Smith', 'Transcript verified');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (4, 'Emily Davis', 'GPA 3.8');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (5, 'Michael Wilson', 'Dean’s List recipient');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (6, 'Jessica Garcia', 'Graduated Cum Laude');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (7, 'David Rodriguez', 'Holds campus leadership role');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (8, 'Sarah Martinez', 'Cleared for study abroad');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (9, 'Daniel Lopez', 'Scholarship awarded');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (10, 'Jennifer Hernandez', 'Completed all required credits');
INSERT INTO StudentData (student_id, student_name, student_data) VALUES (11, 'Chris Lee', 'Pending thesis defense');

-- Commit the changes to finalize the creation and initial data loading
COMMIT;
/