CREATE VIEW BasicInformation AS 
    SELECT idnr, name, login, Students.program, branch
        FROM Students, StudentBranches
            WHERE idnr = student
