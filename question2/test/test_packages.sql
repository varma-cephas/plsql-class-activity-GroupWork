SET SERVEROUTPUT ON;

-- 1. Sample Call to calculate Net Salary
DECLARE
    v_net_salary NUMBER;
    v_employee_id CONSTANT NUMBER := 102;
BEGIN
    v_net_salary := hr_management_pkg.get_net_salary(p_employee_id => v_employee_id);

    IF v_net_salary IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Net Salary Calculation ---');
        DBMS_OUTPUT.PUT_LINE('Gross Salary: ' || TO_CHAR(1200000, '999,999,999.00'));
        DBMS_OUTPUT.PUT_LINE('RSSB Tax (5%): ' || TO_CHAR(1200000 * 0.05, '999,999,999.00'));
        DBMS_OUTPUT.PUT_LINE('Net Salary for Employee ' || v_employee_id || ': ' || TO_CHAR(v_net_salary, '999,999,999.00'));
    END IF;
END;
/

-- 2. Sample Call to execute Dynamic Procedure (Updating Salary)
BEGIN
    hr_management_pkg.execute_hr_dml(
        p_dml_command => 'UPDATE EMPLOYEES SET gross_salary = 1250000 WHERE employee_id = 102'
    );
END;
/

-- 3. Verify the update
SELECT employee_name, gross_salary FROM EMPLOYEES WHERE employee_id = 102;
/