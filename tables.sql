CREATE TABLE Programs (
    pname TEXT PRIMARY KEY,
    pcode TEXT NOT NULL
);

CREATE TABLE Branches (
    bname TEXT,
    program TEXT REFERENCES Programs,
    PRIMARY KEY (bname, program)
);

CREATE TABLE Students (
    idnr CHAR(10) PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL REFERENCES Programs,
    UNIQUE (idnr, program)
);

CREATE TABLE Courses (
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits REAL NOT NULL
);

CREATE TABLE Departments(
    dname TEXT PRIMARY KEY,
    dcode TEXT,
    UNIQUE (dcode)
);

CREATE TABLE Classifications (
    name TEXT PRIMARY KEY
);

CREATE TABLE LimitedCourses (
    code CHAR(6) PRIMARY KEY REFERENCES Courses,
    capacity INT NOT NULL
);

CREATE TABLE WaitingList (
    student CHAR(10) REFERENCES Students,
    course CHAR(6) REFERENCES LimitedCourses,
    position INT NOT NULL,
    PRIMARY KEY (student, course),
    UNIQUE (course, position)
);

CREATE TABLE Registered (
    student CHAR(10) REFERENCES Students,
    course CHAR(6) REFERENCES Courses,
    PRIMARY KEY (student, course)
);

CREATE TABLE Taken (
    student CHAR(10) REFERENCES Students,
    course CHAR(6) REFERENCES Courses,
    grade CHAR(1) NOT NULL,
    PRIMARY KEY (student, course),
    CHECK (grade in ('U', '3', '4', '5'))
);

CREATE TABLE Classified (
    course CHAR(6) REFERENCES Courses,
    classification TEXT REFERENCES Classifications,
    PRIMARY KEY (course, classification)
);

CREATE TABLE Prerequisites (
    predecessor CHAR(6) REFERENCES Courses,
    course CHAR(6) REFERENCES Courses,
    PRIMARY KEY (predecessor, course)
);

CREATE TABLE CourseByDepartment (
    department TEXT REFERENCES Departments,
    course CHAR(6) REFERENCES Courses,
    PRIMARY KEY (department, course)
);

CREATE TABLE RecommendedBranch (
    course CHAR(6) REFERENCES Courses,
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(bname, program),
    PRIMARY KEY (course, branch, program)
);

CREATE TABLE MandatoryBranch (
    course CHAR(6) REFERENCES Courses,
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(bname, program),
    PRIMARY KEY (course, branch, program)
);

CREATE TABLE MandatoryProgram (
    course CHAR(6) REFERENCES Courses,
    program TEXT REFERENCES Programs,
    PRIMARY KEY (course, program)
);

CREATE TABLE ProgramHost (
    department TEXT REFERENCES Departments,
    program TEXT REFERENCES Programs,
    PRIMARY KEY (department, program)
);

CREATE TABLE StudentBranches (
    student CHAR(10) REFERENCES Students,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (student),
    FOREIGN KEY (branch, program) REFERENCES Branches(bname, program),
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program)
)
