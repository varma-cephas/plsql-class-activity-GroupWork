CREATE OR REPLACE PACKAGE BODY hr_management_pkg
AS
    -- RSSB Tax Rate (Used for calculation)
    rssb_rate CONSTANT NUMBER := 0.05; -- Example 5% rate

    ----------------------------------------------------------------------
    -- FUNCTION: get_net_salary (Requirement 1)
    ----------------------------------------------------------------------
    FUNCTION get_net_salary (
        p_employee_id IN EMPLOYEES.employee_id%TYPE
    )
    RETURN NUMBER
    IS
        v_gross_salary EMPLOYEES.gross_salary%TYPE;
        v_rssb_tax     NUMBER;
        v_net_salary   NUMBER;
    BEGIN
        SELECT gross_salary INTO v_gross_salary
        FROM EMPLOYEES
        WHERE employee_id = p_employee_id;

        -- Calculate RSSB Tax
        v_rssb_tax := v_gross_salary * rssb_rate;

        -- Calculate Net Salary
        v_net_salary := v_gross_salary - v_rssb_tax;

        RETURN v_net_salary;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Employee ID ' || p_employee_id || ' not found.');
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error calculating net salary: ' || SQLERRM);
            RETURN NULL;
    END get_net_salary;


    ----------------------------------------------------------------------
    -- PROCEDURE: execute_hr_dml (Requirement 2 & 3 - Dynamic SQL & Security)
    ----------------------------------------------------------------------
    PROCEDURE execute_hr_dml (
        p_dml_command IN VARCHAR2,
        p_parameter_value IN VARCHAR2 DEFAULT NULL
    )
    IS
        v_dynamic_sql VARCHAR2(4000);
        
        /* Security Context Comments (Requirement 3)
           USER vs CURRENT_USER:
           - USER: Returns the name of the schema/user that OWNS the object (i.e., the package, the DEFINER).
           - CURRENT_USER: Returns the name of the user who EXECUTED the object (i.e., the caller/INVOKER).
           
           This package uses AUTHID CURRENT_USER (INVOKER rights).
           The procedure runs with the privileges of CURRENT_USER.
        */
        v_owner_user VARCHAR2(128) := USER;
        v_invoker_user VARCHAR2(128) := CURRENT_USER;
        
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Dynamic HR Operation Initiated ---');
        DBMS_OUTPUT.PUT_LINE('Package Owner (DEFINER/USER): ' || v_owner_user);
        DBMS_OUTPUT.PUT_LINE('Executing User (INVOKER/CURRENT_USER): ' || v_invoker_user);
        
        -- Build the dynamic SQL statement
        v_dynamic_sql := p_dml_command;

        -- Execute the command dynamically
        EXECUTE IMMEDIATE v_dynamic_sql;
        
        DBMS_OUTPUT.PUT_LINE('Success! Rows affected by DML: ' || SQL%ROWCOUNT);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error executing DML: ' || SQLERRM);
    END execute_hr_dml;

END hr_management_pkg;
/