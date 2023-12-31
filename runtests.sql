-- This script deletes everything in your database
\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
-- This script deletes everything in your database
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
-- This line makes psql stop on the first error it encounters
-- You may want to remove this when running tests that are intended to fail
\set ON_ERROR_STOP ON
SET client_min_messages TO NOTICE; -- More talk
\set QUIET false


-- \ir is for include relative, it will run files in the same directory as this file
-- Note that these are not SQL statements but rather Postgres commands (no terminating semicolon). 
\ir tables.sql
\ir views.sql
\ir triggers.sql
\ir inserts.sql





/* SELECT * FROM WaitingList;
SELECT * FROM Registrations;
SELECT * FROM Courses;



SELECT * FROM WaitingList;
SELECT * FROM Registrations; */



-- INSERT INTO Prerequisites VALUES ('CCC555', 'CCC333'); -- TEst


-- INSERT INTO Taken VALUES('1111111111', 'CCC111', '3');
-- INSERT INTO Taken VALUES('1111111111', 'CCC222', '3');
-- INSERT INTO Taken VALUES('1111111111', 'CCC555', 'U');


-- INSERT INTO Registrations VALUES('1111111111', 'CCC444', 'registered');





-- Tests various queries from the assignment, uncomment these as you make progress
-- SELECT idnr, name, login, program, branch FROM BasicInformation ORDER BY idnr;

-- SELECT student, course, courseName, grade, credits FROM FinishedCourses ORDER BY (student, course);

-- SELECT student, course, status FROM Registrations ORDER BY (status, course, student);

-- SELECT student, totalCredits, mandatoryLeft, mathCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;

-- Helper views for PathToGraduation (optional)
--SELECT student, course, credits FROM PassedCourses ORDER BY (student, course);
--SELECT student, course FROM UnreadMandatory ORDER BY (student, course);
--SELECT student, course, credits FROM RecommendedCourses ORDER BY (student, course);


-- Life-hack: When working on a new view you can write it as a query here (without creating a view) and when it works just add CREATE VIEW and put it in views.sql


-- PassedCourses
