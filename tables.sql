CREATE TABLE Students (
    idnr CHAR(10) PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL
);

CREATE TABLE Branches (
    name TEXT,
    program TEXT,
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits REAL NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses (
    code CHAR(6) PRIMARY KEY REFERENCES Courses,
    capacity INT NOT NULL
);

CREATE TABLE StudentBranches (
    student CHAR(10) PRIMARY KEY REFERENCES Students,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Classifications (
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
    course CHAR(6) REFERENCES Courses,
    classification TEXT REFERENCES Classifications,
    PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgram (
    course CHAR(6) REFERENCES Courses,
    program TEXT,
    PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch (
    course CHAR(6) REFERENCES Courses,
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY (course, branch, program)
);

CREATE TABLE RecommendedBranch (
    course CHAR(6) REFERENCES Courses,
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY (course, branch, program)
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

CREATE TABLE WaitingList (
    student CHAR(10) REFERENCES Students,
    course CHAR(6) REFERENCES LimitedCourses,
    position INT NOT NULL,
    PRIMARY KEY (student, course)
);

