CREATE OR REPLACE PACKAGE BODY hospital_mgmt_pkg
AS

    ----------------------------------------------------------------------
    -- PROCEDURE: bulk_load_patients (Uses FORALL)
    ----------------------------------------------------------------------
    PROCEDURE bulk_load_patients (
        p_patients_list IN patient_tbl
    )
    IS
    BEGIN
        -- Requirement: Use bulk processing (FORALL) for efficient insertion
        FORALL i IN p_patients_list.FIRST..p_patients_list.LAST
            INSERT INTO PATIENTS (patient_id, name, age, gender, admitted_status)
            VALUES (
                p_patients_list(i).patient_id,
                p_patients_list(i).name,
                p_patients_list(i).age,
                p_patients_list(i).gender,
                'N' -- Default to Not Admitted
            );
        
        COMMIT; -- Commit the entire batch
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'Bulk load failed: ' || SQLERRM);
    END bulk_load_patients;

    ----------------------------------------------------------------------
    -- FUNCTION: show_all_patients (Returns SYS_REFCURSOR)
    ----------------------------------------------------------------------
    FUNCTION show_all_patients
    RETURN patient_cursor
    IS
        v_patient_cur patient_cursor;
    BEGIN
        OPEN v_patient_cur FOR
            SELECT patient_id, name, age, gender, admitted_status
            FROM PATIENTS
            ORDER BY patient_id;
            
        RETURN v_patient_cur;
    END show_all_patients;

    ----------------------------------------------------------------------
    -- FUNCTION: count_admitted
    ----------------------------------------------------------------------
    FUNCTION count_admitted
    RETURN NUMBER
    IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM PATIENTS
        WHERE admitted_status = 'Y';
        
        RETURN v_count;
    END count_admitted;

    ----------------------------------------------------------------------
    -- PROCEDURE: admit_patient
    ----------------------------------------------------------------------
    PROCEDURE admit_patient (
        p_patient_id IN PATIENTS.patient_id%TYPE
    )
    IS
    BEGIN
        UPDATE PATIENTS
        SET admitted_status = 'Y'
        WHERE patient_id = p_patient_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Patient ID ' || p_patient_id || ' not found for admission.');
        END IF;
        
        COMMIT;
    END admit_patient;

END hospital_mgmt_pkg;
/