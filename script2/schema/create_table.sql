CREATE TABLE EMPLOYEES (
    employee_id NUMBER PRIMARY KEY,
    employee_name VARCHAR2(100),
    gross_salary NUMBER(10, 2),
    hire_date DATE
);

INSERT INTO EMPLOYEES (employee_id, employee_name, gross_salary, hire_date) VALUES (101, 'Alex K.', 500000, DATE '2022-01-15');
INSERT INTO EMPLOYEES (employee_id, employee_name, gross_salary, hire_date) VALUES (102, 'Beryl M.', 1200000, DATE '2023-05-20');
COMMIT;
/