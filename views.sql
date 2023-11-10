CREATE VIEW BasicInformation AS 
    SELECT idnr, name, login, Students.program, branch
        FROM Students LEFT OUTER JOIN StudentBranches ON idnr=student;

CREATE VIEW FinishedCourses AS
    SELECT student, course, name AS coursename, grade, credits
        FROM Taken LEFT OUTER JOIN Courses ON course=code;


CREATE VIEW Registrations AS
    SELECT idnr AS student, course, COALESCE(student, 'waiting') AS status
        FROM Registered RIGHT OUTER JOIN Students ON student=idnr;

