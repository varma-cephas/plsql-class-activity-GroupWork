CREATE OR REPLACE PACKAGE hr_management_pkg
AUTHID CURRENT_USER -- Security Context: Defines the package will run with INVOKER rights.
AS
    -- Requirement 1: Function to calculate RSSB tax and return net salary
    FUNCTION get_net_salary (
        p_employee_id IN EMPLOYEES.employee_id%TYPE
    )
    RETURN NUMBER;

    -- Requirement 2: Dynamic Procedure for HR Operations
    PROCEDURE execute_hr_dml (
        p_dml_command IN VARCHAR2,
        p_parameter_value IN VARCHAR2 DEFAULT NULL
    );

END hr_management_pkg;
/


