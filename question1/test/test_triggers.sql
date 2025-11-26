SET SERVEROUTPUT ON;

DECLARE
    -- Custom error variable to catch the specific block raised by the trigger
    e_access_denied EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_access_denied, -20001);
    
    v_log_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Testing System Access Policy ---');

    ----------------------------------------------------------------------
    -- TEST 1: SUCCESSFUL ACCESS (Must run Mon-Fri, 8:00 AM - 4:59 PM)
    ----------------------------------------------------------------------
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '1. Attempting successful access (Should pass):');
    
    INSERT INTO SensitiveData (record_id, customer_name, secret_value)
    VALUES (2, 'Allowed User', 'Data saved during work hours');
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('   SUCCESS: Data inserted without error.');
    
    ----------------------------------------------------------------------
    -- TEST 2: SIMULATED VIOLATION (Will be blocked)
    ----------------------------------------------------------------------
    
    -- NOTE: To test the 'outside hours' logic, we must force the server to think it's outside 8-5.
    -- Since we cannot easily change the time, we will rely on the trigger blocking if you run this 
    -- outside Mon-Fri or outside 8 AM - 5 PM CAT time.

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '2. Attempting unauthorized access (Should be blocked):');
    
    BEGIN
        -- This statement attempts to modify data, which should fire trg_AccessEnforcer
        INSERT INTO SensitiveData (record_id, customer_name, secret_value)
        VALUES (3, 'Blocked User', 'Unauthorized attempt');
        COMMIT;
        
        -- If the trigger failed to raise the error, this line will execute (which is a failure)
        DBMS_OUTPUT.PUT_LINE('   *** TEST FAILED: Access was NOT blocked! ***');
        
    EXCEPTION
        WHEN e_access_denied THEN
            DBMS_OUTPUT.PUT_LINE('   BLOCKED: Trigger 1 (Enforcer) successfully raised error -20001.');
            -- Crucial: The insert was rolled back here.
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ERROR: Unexpected error during block test: ' || SQLERRM);
    END;

    ----------------------------------------------------------------------
    -- TEST 3: VERIFY AUDIT LOG (Log must survive the rollback)
    ----------------------------------------------------------------------
    
    -- Check how many new failed attempts were logged by Trigger 2 (Logger)
    SELECT COUNT(*) 
    INTO v_log_count
    FROM AccessViolations
    WHERE username = USER 
      AND violation_reason LIKE 'Attempt blocked by%'; -- Use the specific reason defined in Trigger 2
      
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '3. Verifying Audit Log (Must show 1 new entry):');
    DBMS_OUTPUT.PUT_LINE('   Audit Log Count for current user: ' || v_log_count);
    
    IF v_log_count >= 1 THEN
        DBMS_OUTPUT.PUT_LINE('   SUCCESS: Trigger 2 (Logger) successfully saved the audit log via autonomous transaction.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('   *** TEST FAILED: Audit log entry was NOT found! ***');
    END IF;

END;
/