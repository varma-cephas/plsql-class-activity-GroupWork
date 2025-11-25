ALTER SESSION SET CONTAINER = CDB$ROOT;
/

-- You must be logged in as a privileged user (e.g., SYS or SYSTEM) in CDB$ROOT

-- 1. Create the user with the mandatory C## prefix.
-- The 'CONTAINER=ALL' clause makes this user accessible from all PDBs.
CREATE USER C##SYSTEM_ACCESS_OWNER IDENTIFIED BY mypassword1 CONTAINER=ALL;
/

-- 2. Grant necessary privileges.
GRANT CONNECT, RESOURCE, CREATE SESSION, CREATE TRIGGER, DBA TO C##SYSTEM_ACCESS_OWNER CONTAINER=ALL;
/


-- create new pdb for testing
CREATE PLUGGABLE DATABASE admin_access_pdb
ADMIN USER SYSTEM_ACCESS_OWNER IDENTIFIED BY mypassword1
FILE_NAME_CONVERT = ('/pdbseed/', '/hr_access_pdb/');
/


-- opens the newly created pdb
ALTER PLUGGABLE DATABASE admin_access_pdb OPEN;


-- connects user
CONN C##SYSTEM_ACCESS_OWNER/mypassword1@localhost:1521/ADMIN_ACCESS_PDB