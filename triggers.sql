
-- Tries to reg student
CREATE FUNCTION check_reg() RETURNS trigger AS
$$
DECLARE registeredStudents INT;
DECLARE maxCapacity INT;


BEGIN

-- Handle NULL and not exist values
IF NEW.student IS NULL THEN
    RAISE EXCEPTION 'Student can not be NULL';
END IF;

IF NOT EXISTS (SELECT idnr FROM Students WHERE Students.idnr = NEW.student) THEN
    RAISE EXCEPTION 'Student does not exist';
END IF;

IF NEW.course IS NULL THEN
    RAISE EXCEPTION 'Course can not be NULL';
END IF;


-- Check if course is already passed
IF EXISTS (SELECT * FROM Taken WHERE (Taken.student, Taken.course) = (NEW.student, NEW.course) AND Taken.grade != 'U') THEN
    RAISE EXCEPTION 'Student has already passed this course';
END IF;


-- Check if IN Registrations
IF EXISTS (SELECT * FROM Registrations WHERE (Registrations.student, Registrations.course) = (NEW.student, NEW.course)) THEN
    RAISE EXCEPTION 'Student is already registered or waiting';
END IF;


-- Checking if course needs a prerequisite AND if student has taken that course
IF ((SELECT COUNT(*) FROM Prerequisites, Taken
                WHERE predecessor = Taken.course
                    AND student = NEW.student AND grade != 'U' AND Prerequisites.course = NEW.course) !=
                        (SELECT COUNT(*) FROM Prerequisites
                            WHERE Prerequisites.course = NEW.course)) THEN
                        RAISE EXCEPTION 'Prerequisites not taken';
END IF;


-- Check if course has capacity AND if it is already full THEN ADD student to waiting list
IF EXISTS (SELECT code FROM LimitedCourses WHERE LimitedCourses.code = NEW.course) THEN
    IF (SELECT capacity FROM LimitedCourses WHERE LimitedCourses.code = NEW.course) <=
        (SELECT COUNT(*) FROM Registered WHERE Registered.course = NEW.course) THEN
            INSERT INTO WaitingList VALUES (NEW.student, NEW.course, nextNumber(NEW.course));
                RETURN NEW;
                END IF;
END IF;


INSERT INTO Registered VALUES (NEW.student, NEW.course);


RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION nextNumber(CHAR(6))
    RETURNS BIGINT AS
$$ SELECT COUNT(*) +1 FROM WaitingList WHERE course =$1
$$ LANGUAGE SQL;



-- Tries to unreg student
CREATE FUNCTION uncheck_reg() RETURNS trigger AS 
$$
DECLARE theStudent VARCHAR;
BEGIN


-- Student, Course pair do not exist in Registered
IF NOT EXISTS (SELECT student, course FROM Registered WHERE (Registered.student, Registered.course) = (OLD.student, OLD.course) UNION
                SELECT student, course FROM WaitingList WHERE (WaitingList.student, WaitingList.course) = (OLD.student, OLD.course)) THEN
    RAISE EXCEPTION 'Student is not registered or waiting';
END IF;


-- IF student was registered THEN remove from Registered AND ADD first person from WaitingList (if not overfull)
theStudent := (SELECT student from WaitingList WHERE WaitingList.position=1 AND WaitingList.course = OLD.course);
IF ((SELECT COUNT(*) FROM Registered WHERE Registered.course = OLD.course) <= (SELECT capacity FROM LimitedCourses WHERE LimitedCourses.code = OLD.course)) THEN
    
    
    DELETE FROM WaitingList WHERE WaitingList.student = theStudent AND WaitingList.course = OLD.course;
    INSERT INTO Registrations VALUES (theStudent, OLD.course, 'registered');

    DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;


END IF;


-- IF student was IN WaitingList THEN remove from list AND move up students in queue




RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION decreaseQueue()
    RETURNS trigger AS $$
BEGIN
    UPDATE WaitingList SET position = position-1
        WHERE course = OLD.course AND position > OLD.position;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER CheckReg INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE check_reg();

CREATE TRIGGER CheckUnReg INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE uncheck_reg();

CREATE TRIGGER UpdateWaitingList AFTER DELETE ON WaitingList
    FOR EACH ROW EXECUTE PROCEDURE decreaseQueue();
