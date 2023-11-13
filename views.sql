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


CREATE VIEW PathToGraduation AS
WITH
PassedCourses AS
(SELECT student, course, credits
    FROM Taken, Courses
        WHERE course=code AND grade IN ('3', '4', '5')),

UnreadMandatory AS
((SELECT student, course
    FROM (

(SELECT idnr AS student, course
    FROM Students NATURAL JOIN MandatoryProgram)
UNION
(SELECT student, course
    FROM StudentBranches NATURAL JOIN MandatoryBranch)))

EXCEPT
(SELECT student, course FROM FinishedCourses WHERE grade != 'U')),

totalCredits AS
(SELECT student, SUM(credits) AS totalcredits
    FROM Taken LEFT OUTER JOIN Courses ON code=course
        WHERE grade != 'U'
            GROUP BY student),

mandatoryLeft AS
(SELECT student, COUNT(course) AS mandatoryleft
    FROM UnreadMandatory
        GROUP BY student),

mathCredits AS
(SELECT student, SUM(credits) AS mathcredits 
    FROM PassedCourses RIGHT OUTER JOIN Classified USING (course)
        WHERE classification = 'math'
            GROUP BY student),

seminarCourses AS
(SELECT student, COUNT(course) AS seminarcourses
    FROM PassedCourses RIGHT OUTER JOIN Classified USING (course)
        WHERE classification = 'seminar'
            GROUP BY student),

RecommendedCourses AS
(SELECT student, course, credits
    FROM RecommendedBranch NATURAL JOIN
        StudentBranches LEFT OUTER JOIN
            Courses ON(course=code)
                ),

qualified AS
((SELECT idnr AS student, 't' AS qualified
    FROM Students
        WHERE idnr NOT IN (SELECT student FROM mandatoryLeft))

INTERSECT

(SELECT student, 't' AS qualified
    FROM mathCredits
        WHERE mathcredits >= 20)

INTERSECT

(SELECT student, 't' AS qualified
    FROM seminarCourses
        WHERE seminarcourses >= 1)

INTERSECT

(SELECT student, 't' AS qualified
    FROM RecommendedCourses
        WHERE (student, course) IN (SELECT student, course FROM PassedCourses)
            GROUP BY(student)
                HAVING SUM(credits) >= 10))

SELECT idnr AS student, COALESCE(totalcredits, 0) AS totalcredits, COALESCE(mandatoryleft, 0) AS mandatoryleft, COALESCE(mathcredits, 0) AS mathcredits, COALESCE(seminarcourses, 0) AS seminarcourses, COALESCE(qualified, 'f') AS qualified
    FROM Students LEFT OUTER JOIN totalCredits ON idnr=totalCredits.student
    LEFT OUTER JOIN mandatoryLeft ON idnr=mandatoryLeft.student
    LEFT OUTER JOIN mathCredits ON idnr=mathCredits.student
    LEFT OUTER JOIN seminarCourses ON idnr=seminarCourses.student
    LEFT OUTER JOIN qualified ON idnr=qualified.student

