CREATE OR REPLACE TRIGGER trg_AccessEnforcer
BEFORE INSERT OR UPDATE OR DELETE ON StudentData
FOR EACH ROW
DECLARE
    v_day      VARCHAR2(3);
    v_hour     NUMBER;
    
    e_access_denied EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_access_denied, -20001);
BEGIN
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    v_hour := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));

    -- Rule 1: Sabbath Check (Saturday or Sunday)
    IF v_day IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Access Denied: Sabbath restriction (Saturday or Sunday).');
    END IF;

    -- Rule 2: Time Check (Mon-Fri, outside 08:00 to 17:00)
    IF v_day NOT IN ('SAT', 'SUN') AND (v_hour < 8 OR v_hour >= 17) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Access Denied: Outside Mon-Fri 8:00 AM to 5:00 PM window.');
    END IF;
    
EXCEPTION
    -- Catch the raised error and re-raise it to halt the transaction
    WHEN OTHERS THEN
        RAISE;

END trg_AccessEnforcer;
/