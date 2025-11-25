# plsql-class-activity-GroupWork
PL/SQL class Activity GroupWork

## Classwork Summary: Advanced PL/SQL & Database Security Implementation

This class work covered four distinct scenarios, focusing on core database development techniques: Triggers for Security Enforcement, PL/SQL Packages for Business Logic, and efficient Data Management via Bulk Processing.

***

### I. System Access Policy (Triggers) 

**Overview:** The goal was to enforce a system access policy (Mon-Fri, 8 AM–5 PM access only) and ensure any unauthorized access attempts were blocked *and* logged for auditing.

**Implementation:**
* **Tables Created:** `SensitiveData` (the protected table) and `AccessViolations` (the audit log).
* **Solution:** Two separate PL/SQL triggers were created, linked by the critical **`PRAGMA AUTONOMOUS_TRANSACTION`** to handle the "Rollback Paradox."
    * **Trigger 1 (`trg_AccessEnforcer`):** Fired `BEFORE` DML. It checked the `SYSDATE` (day and hour) and raised an application error (`ORA-20001`) to block the transaction immediately if a violation occurred.
    * **Trigger 2 (`trg_AccessLogger`):** Fired `AFTER` DML. It was defined with `AUTONOMOUS_TRANSACTION`. If a violation was detected (implying Trigger 1 fired and the transaction would fail), this trigger inserted the violation details into `AccessViolations` and executed an independent **`COMMIT`** to save the log, ensuring the audit trail survived the main transaction's rollback.


### II. HR Employee Management System (Packages & Security) 

**Overview:** The requirement was to design a PL/SQL package for HR tasks, demonstrating the use of functions, dynamic procedures, and controlling the security context.

**Implementation:**
* **Package Created:** `hr_management_pkg`.
* **Security Model:** The package used **`AUTHID CURRENT_USER`** (Invoker's Rights) to ensure the procedures and functions ran with the privileges of the executing user, not the package owner (Definer).
* **Functions:**
    * `get_net_salary`: Calculated a tax (e.g., 5% RSSB) and returned the employee's net salary.
* **Procedure:**
    * `execute_hr_dml`: Used **Dynamic SQL (`EXECUTE IMMEDIATE`)** to accept a DML string (`UPDATE`, `INSERT`, etc.) as input, allowing flexible HR operations while ensuring the code compiled statically.
* **Security Context:** The procedure demonstrated the difference between **`USER`** (the owner/Definer of the package) and **`CURRENT_USER`** (the Invoker/Executor of the package).


### III. Suspicious Login Monitoring (Advanced Triggers) 

**Overview:** The goal was to monitor user logins and issue an immediate security alert if any user failed to log in more than two times in the same day.

**Implementation:**
* **Tables Created:** `LOGIN_AUDIT` (to track all attempts) and `SECURITY_ALERTS` (to store policy violations).
* **Solution:** A single `AFTER INSERT` trigger (`trg_CheckSuspiciousLogin`) was created on the `LOGIN_AUDIT` table.
    * **Logic:** The trigger checked if the inserted record's status was 'FAILED'. If so, it performed a **`COUNT(*)`** query on `LOGIN_AUDIT` for the same user on the current day (`TRUNC(SYSTIMESTAMP)`).
    * **Alerting:** If the count was $\ge 3$, the trigger, operating under **`PRAGMA AUTONOMOUS_TRANSACTION`**, inserted a new record into `SECURITY_ALERTS` and executed an independent **`COMMIT`**.
    * **Optional:** A second trigger was outlined to demonstrate how to use `UTL_MAIL` to send an external email notification whenever a record was inserted into `SECURITY_ALERTS`.


### IV. Hospital Management (Bulk Processing) 🩺

**Overview:** The requirement was to design a package for efficient patient management, utilizing collections and bulk processing for high-volume data operations.

**Implementation:**
* **Tables Created:** `PATIENTS` and `DOCTORS`.
* **Package Created:** `hospital_mgmt_pkg`.
* **Bulk Collection:** A custom **`patient_tbl`** collection type was defined (a nested table of a `patient_rec` record type) to hold multiple patient records in memory.
* **Procedures/Functions:**
    * `bulk_load_patients`: Used the **`FORALL`** statement to insert all records from the input collection (`p_patients_list`) into the `PATIENTS` table with a single context switch, ensuring optimal performance.
    * `admit_patient`: Updated the `admitted_status` for a single patient.
    * `count_admitted`: A function to return the total number of admitted patients.
    * `show_all_patients`: A function that returns a **`SYS_REFCURSOR`**, allowing the calling application to fetch and display the full patient list efficiently.