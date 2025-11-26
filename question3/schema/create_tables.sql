-- Sequence for Alert IDs
CREATE SEQUENCE security_alerts_seq START WITH 1 INCREMENT BY 1;
/

-- 1. Table to store ALL login attempts (Success and Failed)
CREATE TABLE LOGIN_AUDIT (
    audit_id NUMBER GENERATED AS IDENTITY PRIMARY KEY, -- Oracle 12c+ Identity Column
    username VARCHAR2(50) NOT NULL,
    attempt_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(10) CHECK (status IN ('SUCCESS', 'FAILED')),
    ip_address VARCHAR2(40) 
);
/

-- 2. Table to store security alerts when policy is violated
CREATE TABLE SECURITY_ALERTS (
    alert_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) NOT NULL,
    failed_attempts_count NUMBER NOT NULL,
    alert_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    alert_message VARCHAR2(255),
    notify_contact VARCHAR2(100)
);
/