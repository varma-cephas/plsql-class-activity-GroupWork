-- 1. Patients Table
CREATE TABLE PATIENTS (
    patient_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    age NUMBER(3) NOT NULL,
    gender VARCHAR2(10),
    admitted_status VARCHAR2(10) DEFAULT 'N' CHECK (admitted_status IN ('Y', 'N'))
);
/

-- 2. Doctors Table
CREATE TABLE DOCTORS (
    doctor_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    specialty VARCHAR2(50)
);
/
-- Add some initial data
INSERT INTO DOCTORS (doctor_id, name, specialty) VALUES (1, 'Dr. Aris', 'Cardiology');
INSERT INTO DOCTORS (doctor_id, name, specialty) VALUES (2, 'Dr. Banesa', 'General Practice');
COMMIT;
/