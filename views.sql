CREATE VIEW BasicInformation AS 
    SELECT idnr, name, login, Students.program, branch
        FROM Students LEFT OUTER JOIN StudentBranches ON idnr=student;

CREATE VIEW FinishedCourses AS
    SELECT student, course, name AS courseName, grade, credits
        FROM Taken LEFT OUTER JOIN Courses ON course=code;


CREATE VIEW Registrations AS
    (SELECT idnr AS student, course, 'registered' AS status
        FROM Students JOIN Registered ON idnr=student)
    UNION
    (SELECT idnr AS student, course, 'waiting' AS status 
        FROM Students, Registered
            WHERE (idnr, course) IN (SELECT student, course FROM WaitingList));


