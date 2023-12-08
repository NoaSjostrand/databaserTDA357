import psycopg2


class PortalConnection:
    def __init__(self):
        self.conn = psycopg2.connect(
            host="localhost",
            user="postgres",
            password="postgres")
        self.conn.autocommit = True

    def getInfo(self,student):
      with self.conn.cursor() as cur:
        # Here's a start of the code for this part

        sql = """
                SELECT jsonb_build_object(
                     'student', s.idnr
                    ,'name', s.name
                    ,'login', s.login
                    ,'program', s.program
                    ,'branch', s.branch
                    ,'finished', (SELECT jsonb_agg(jsonb_build_object('course',Courses.name, 'code',Courses.code, 'credits',Courses.credits, 'grade',grade)) FROM FinishedCourses LEFT OUTER JOIN Courses ON Courses.code=FinishedCourses.course WHERE student=%s)
                    ,'registered', (SELECT jsonb_agg(jsonb_build_object('course',Courses.name, 'code',Courses.code, 'status',status)) FROM Registrations LEFT OUTER JOIN Courses ON Courses.code=Registrations.course WHERE student=%s)
                    ,'seminarCourses', (SELECT seminarcourses FROM PathToGraduation WHERE student=%s)
                    ,'mathCredits', (SELECT mathcredits FROM PathToGraduation WHERE student=%s)
                    ,'totalCredits', (SELECT totalcredits FROM PathToGraduation WHERE student=%s)
                    ,'canGraduate', (SELECT qualified FROM PathToGraduation WHERE student=%s)
                ) :: TEXT
                FROM BasicInformation AS s JOIN Registrations AS r ON idnr=r.student LEFT OUTER JOIN Courses AS c ON (r.course = c.code)
                WHERE s.idnr = %s;"""
        cur.execute(sql, (student, student, student, student, student, student, student,))
        res = cur.fetchone()
        if res:
            return (str(res[0]))
        else:
            return """{"student":"Not found :("}"""

    def register(self, student, courseCode):
        try:
            #Your code goes here! Remove this comment and the line below it.
            with self.conn.cursor() as cur:
                cur.execute("""
                        INSERT INTO Registrations VALUES (%s,%s)""", (student, courseCode))
            
            if cur.rowcount == 0:
                return '{"success":false, "error": "Not a valid input"}'
            return """{"success":true}"""
        except psycopg2.Error as e:
            message = getError(e)
            return '{"success":false, "error": "'+message+'"}'

    def unregister(self, student, courseCode):
        try:
            #Your code goes here! Remove this comment and the line below it. 
            with self.conn.cursor() as cur:

                cur.execute("""
                        DELETE FROM Registrations WHERE student = %s AND course = %s""", (student, courseCode))
            
            if cur.rowcount == 0:
                return '{"success":false, "error": "Not a valid input"}'
            return '{"success":true}'
        except psycopg2.Error as e:
            message = getError(e)
            return '{"success":false, "error": "'+message+'"}'

def getError(e):
    message = repr(e)
    message = message.replace("\\n"," ")
    message = message.replace("\"","\\\"")
    return message

