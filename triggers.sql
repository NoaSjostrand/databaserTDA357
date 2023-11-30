CREATE FUNCTION check_reg() RETURNS trigger AS
$$
DECLARE registeredStudents INT;
DECLARE maxCapacity INT;


BEGIN

IF NEW.student IS NULL THEN
    RAISE EXCEPTION 'Student can not be NULL';
END IF;

IF NOT EXISTS (SELECT idnr FROM Students WHERE Students.idnr = NEW.student) THEN
    RAISE EXCEPTION 'Student does not exist';
END IF;

IF NEW.course IS NULL THEN
    RAISE EXCEPTION 'course can not be NULL';
END IF;

IF NOT EXISTS (SELECT course FROM Prerequisites WHERE Prerequisites.course = NEW.course) THEN
    NULL;

ELSIF ((SELECT COUNT(*) FROM Prerequisites, Taken
                WHERE predecessor = Taken.course
                    AND student = NEW.student AND grade != 'U' AND Prerequisites.course = NEW.course) !=
                        (SELECT COUNT(*) FROM Prerequisites
                            WHERE Prerequisites.course = NEW.course)) THEN
                        RAISE EXCEPTION 'prerequisites not taken';
END IF;



INSERT INTO Registered VALUES (NEW.student, NEW.course);


RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER CheckReg INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE check_reg();