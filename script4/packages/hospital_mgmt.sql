CREATE OR REPLACE PACKAGE hospital_mgmt_pkg
AS
    -- Define a Record Type for a single patient record
    TYPE patient_rec IS RECORD (
        patient_id PATIENTS.patient_id%TYPE,
        name PATIENTS.name%TYPE,
        age PATIENTS.age%TYPE,
        gender PATIENTS.gender%TYPE
    );

    -- Define a Collection Type (Table) to hold multiple patients for bulk processing
    TYPE patient_tbl IS TABLE OF patient_rec INDEX BY PLS_INTEGER;
    
    -- Define a Return Type for the function that displays all patients (SYS_REFCURSOR)
    TYPE patient_cursor IS REF CURSOR;
    
    ----------------------------------------------------------------------
    -- Procedures and Functions (Requirements)
    ----------------------------------------------------------------------

    -- Procedure to insert multiple patient records at once using bulk collection.
    PROCEDURE bulk_load_patients (
        p_patients_list IN patient_tbl
    );

    -- Function to display all patients (returns a cursor).
    FUNCTION show_all_patients
    RETURN patient_cursor;

    -- Function to return the number of patients currently admitted.
    FUNCTION count_admitted
    RETURN NUMBER;

    -- Procedure to update a patient’s status as admitted.
    PROCEDURE admit_patient (
        p_patient_id IN PATIENTS.patient_id%TYPE
    );

END hospital_mgmt_pkg;
/

