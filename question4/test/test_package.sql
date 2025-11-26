SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- Declare variables for the bulk collection and cursor
DECLARE
    -- Variable of the custom collection type
    v_new_patients hospital_mgmt_pkg.patient_tbl; 
    
    -- Variable for the ref cursor return type
    v_all_patients_cur hospital_mgmt_pkg.patient_cursor; 
    
    -- Variables to hold fetched data from the cursor
    v_id PATIENTS.patient_id%TYPE;
    v_name PATIENTS.name%TYPE;
    v_status PATIENTS.admitted_status%TYPE;
    
    v_admitted_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Starting Hospital Management Package Test ---');
    
    ------------------------------------------------
    -- TEST 1: bulk_load_patients
    ------------------------------------------------
    
    -- Load data into the collection
    v_new_patients(1).patient_id := 101;
    v_new_patients(1).name := 'Mary Jones';
    v_new_patients(1).age := 45;
    v_new_patients(1).gender := 'Female';

    v_new_patients(2).patient_id := 102;
    v_new_patients(2).name := 'Ted Miller';
    v_new_patients(2).age := 62;
    v_new_patients(2).gender := 'Male';

    v_new_patients(3).patient_id := 103;
    v_new_patients(3).name := 'Sue Kim';
    v_new_patients(3).age := 28;
    v_new_patients(3).gender := 'Female';
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '1. Testing Bulk Load...');
    hospital_mgmt_pkg.bulk_load_patients(v_new_patients);
    DBMS_OUTPUT.PUT_LINE('   Loaded ' || v_new_patients.COUNT || ' patients.');

    ------------------------------------------------
    -- TEST 2: admit_patient & count_admitted
    ------------------------------------------------
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '2. Testing Admission and Counting...');
    
    -- Admit Patient 101
    hospital_mgmt_pkg.admit_patient(p_patient_id => 101);
    DBMS_OUTPUT.PUT_LINE('   Patient 101 admitted.');
    
    -- Admit Patient 103
    hospital_mgmt_pkg.admit_patient(p_patient_id => 103);
    DBMS_OUTPUT.PUT_LINE('   Patient 103 admitted.');
    
    -- Verify the count
    v_admitted_count := hospital_mgmt_pkg.count_admitted;
    DBMS_OUTPUT.PUT_LINE('   Current Admitted Count: ' || v_admitted_count);
    
    ------------------------------------------------
    -- TEST 3: show_all_patients (Cursor Return)
    ------------------------------------------------

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '3. Testing Show All Patients (Cursor Output):');
    
    v_all_patients_cur := hospital_mgmt_pkg.show_all_patients;
    
    -- Fetch and display the results from the cursor
    LOOP
        FETCH v_all_patients_cur INTO v_id, v_name, v_status;
        EXIT WHEN v_all_patients_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('   ID: ' || v_id || ' | Name: ' || RPAD(v_name, 12) || ' | Status: ' || v_status);
    END LOOP;
    
    CLOSE v_all_patients_cur;
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test Complete ---');

END;
/