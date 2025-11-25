CREATE OR REPLACE TRIGGER trg_AccessLogger
AFTER INSERT OR UPDATE OR DELETE ON SensitiveData
FOR EACH ROW
DECLARE
    -- CRITICAL: This allows the log to be committed even if the main action fails.
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    v_day      VARCHAR2(3);
    v_hour     NUMBER;
    v_action   VARCHAR2(10);
    v_reason   VARCHAR2(255);
BEGIN
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    v_hour := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));

    -- Determine the attempted action
    IF INSERTING THEN v_action := 'INSERT'; 
    ELSIF UPDATING THEN v_action := 'UPDATE'; 
    ELSE v_action := 'DELETE';
    END IF;

    -- Determine the violation reason (Logic duplication is necessary for logging clarity)
    IF v_day IN ('SAT', 'SUN') THEN
        v_reason := 'Attempt blocked by Sabbath policy.';
    ELSIF v_day NOT IN ('SAT', 'SUN') AND (v_hour < 8 OR v_hour >= 17) THEN
        v_reason := 'Attempt blocked by Operating Hours policy.';
    ELSE
        -- If no violation reason is found, exit the logging trigger
        RETURN;
    END IF;

    -- Only if a violation is detected, insert the log entry
    INSERT INTO AccessViolations (log_id, user_name, attempt_date, action_attempted, violation_reason)
    VALUES (access_violations_seq.NEXTVAL, USER, SYSDATE, v_action, v_reason);

    -- Commit the log entry independently
    COMMIT;
    
EXCEPTION
    -- Since this is a logging mechanism, we don't want it to cause further errors
    WHEN OTHERS THEN
        -- In a production environment, you would log this failure to a separate system
        NULL;
END trg_AccessLogger;
/