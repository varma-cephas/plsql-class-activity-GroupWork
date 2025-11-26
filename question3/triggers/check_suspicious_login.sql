CREATE OR REPLACE TRIGGER trg_CheckSuspiciousLogin
AFTER INSERT ON LOGIN_AUDIT
FOR EACH ROW
DECLARE
    -- Necessary to commit the alert independently of the main transaction (login attempt)
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    v_failed_count NUMBER;
    v_alert_msg    VARCHAR2(255);
BEGIN
    -- Check if the inserted record is a FAILED attempt
    IF :NEW.status = 'FAILED' THEN
        
        -- 1. Count same-day failed attempts for the specific user (Requirement 3)
        SELECT COUNT(*)
        INTO v_failed_count
        FROM LOGIN_AUDIT
        WHERE username = :NEW.username
          AND status = 'FAILED'
          -- Count attempts from the beginning of the day (TRUNC(SYSDATE))
          AND attempt_time >= TRUNC(SYSTIMESTAMP); 

        -- 2. Check Policy: If failed attempts exceed 2 (i.e., the count is 3 or more)
        IF v_failed_count >= 3 THEN
            
            -- Prepare Alert Message
            v_alert_msg := 'Suspicious Activity: ' || :NEW.username || 
                           ' failed to log in ' || v_failed_count || ' times today.';

            -- 3. Insert new record into SECURITY_ALERTS
            INSERT INTO SECURITY_ALERTS (
                alert_id,
                username,
                failed_attempts_count,
                alert_time,
                alert_message,
                notify_contact
            )
            VALUES (
                security_alerts_seq.NEXTVAL,
                :NEW.username,
                v_failed_count,
                SYSTIMESTAMP,
                v_alert_msg,
                'security@yourorg.com' -- Default security email
            );

            -- Commit the alert independently so it is saved immediately
            COMMIT;
            
        END IF;
    END IF;
    
EXCEPTION
    -- Catch exceptions, log them (optional), and ensure the main process continues
    WHEN OTHERS THEN
        -- DBMS_OUTPUT.PUT_LINE('ALERT TRIGGER ERROR: ' || SQLERRM);
        -- In a production environment, you would log this to a separate error table.
        NULL;
END;
/