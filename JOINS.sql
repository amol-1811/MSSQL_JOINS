CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    enrollment_date DATE
);

INSERT INTO Students (student_id, name, email, enrollment_date) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com', '2023-08-15'),
(2, 'RISHI KHARADE', 'bob.smith@example.com', '2023-08-15'),
(3, 'Amol Gosavi', 'charlie.brown@example.com', '2023-08-15');

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    course_description VARCHAR(255)
);

-- Insert sample data
INSERT INTO Courses (course_id, course_name, course_description) VALUES
(101, 'Introduction to Programming', 'Learn the basics of programming using Python.'),
(102, 'Data Structures', 'Study various data structures and their applications.'),
(103, 'Database Management', 'Understand the principles of database design and management.');

CREATE TABLE Assignments (
	assignment_id INT PRIMARY KEY,
	course_id INT,
	title VARCHAR(100),
	due_date DATE,
	FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- Insert sample data
INSERT INTO Assignments (assignment_id, course_id, title, due_date) VALUES
(1, 101, 'Assignment 1', '2024-01-15'),
(2, 101, 'Assignment 2', '2024-02-10'),
(3, 102, 'Midterm Project', '2024-03-01'),
(4, 103, 'Final Exam', '2024-04-20');

CREATE TABLE Grades (
    grade_id INT PRIMARY KEY,
    student_id INT,
    assignment_id INT,
    score DECIMAL(5, 2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id)
);

INSERT INTO Grades (grade_id, student_id, assignment_id, score) VALUES
(1, 1, 1, 85.5),
(2, 2, 1, 90.0),
(3, 3, 2, 75.0),
(4, 1, 3, 88.0),
(5, 2, 4, 92.0);

CREATE TABLE Instructors (
    instructor_id INT PRIMARY KEY,
    course_id INT,
    name VARCHAR(50),
    email VARCHAR(100),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

INSERT INTO Instructors (instructor_id, course_id, name, email) VALUES
(1, 101, 'Dr. Smith', 'smith@example.com'),
(2, 102, 'Dr. Johnson', 'johnson@example.com'),
(3, 103, 'Dr. Lee', 'lee@example.com');

CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    attendance_date DATE,
    status VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

INSERT INTO Attendance (attendance_id, student_id, course_id, attendance_date, status) VALUES
(1, 1, 101, '2024-01-10', 'Present'),
(2, 2, 101, '2024-01-10', 'Absent'),
(3, 3, 102, '2024-02-05', 'Present'),
(4, 1, 103, '2024-02-07', 'Absent'),
(5, 2, 103, '2024-02-07', 'Present');

CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

INSERT INTO Enrollments (enrollment_id, student_id, course_id, enrollment_date) VALUES
(1, 1, 101, '2023-08-15'), 
(2, 1, 102, '2023-08-15'),  
(3, 2, 101, '2023-08-15'),
(4, 3, 103, '2023-08-15'); 

--Retrieve a List of Students Along with the Names of Courses They Are Enrolled In
SELECT Students.student_id, Students.name AS student_name,
Courses.course_id, Courses.course_name
FROM Students
INNER JOIN Enrollments ON Students.student_id = Enrollments.student_id
INNER JOIN Courses ON Enrollments.course_id = Courses.course_id;

-- List All Students and the Courses They Are Enrolled In, Including Students Not Enrolled in Any Course
SELECT Students.student_id, Students.name AS student_name, Courses.course_id, Courses.course_name
FROM Students
LEFT JOIN Enrollments ON Students.student_id = Enrollments.student_id
LEFT JOIN Courses ON Enrollments.course_id = Courses.course_id;

--List All Courses and the Students Enrolled in Each Course, Including Courses with No Students
SELECT Courses.course_id, Courses.course_name, Students.student_id, Students.name AS student_name
FROM Courses
LEFT JOIN Enrollments ON Courses.course_id = Enrollments.course_id
LEFT JOIN Students ON Enrollments.student_id = Students.student_id;

-- Full Outer Join: Retrieve a List of All Students and Courses, Including Students Without Any Courses and Courses Without Any Students
SELECT Students.student_id, Students.name AS student_name, Courses.course_id, Courses.course_name
FROM Students
FULL OUTER JOIN Enrollments ON Students.student_id = Enrollments.student_id
FULL OUTER JOIN Courses ON Enrollments.course_id = Courses.course_id;

--Retrieve Each Student's Name Along with Their Course Name and Instructor’s Name
SELECT Students.name AS student_name, Courses.course_name, Instructors.name AS instructor_name
FROM Students
INNER JOIN Enrollments ON Students.student_id = Enrollments.student_id
INNER JOIN Courses ON Enrollments.course_id = Courses.course_id
INNER JOIN Instructors ON Courses.course_id = Instructors.course_id;

-- Use LEFT JOIN to Find Students Who Are Not Enrolled in Any Course
SELECT Students.student_id, Students.name AS student_name
FROM Students
LEFT JOIN Enrollments ON Students.student_id = Enrollments.student_id
WHERE Enrollments.course_id IS NULL;

--Retrieve the Title of Each Assignment Along with the Student’s Name and Their Score
SELECT Assignments.title AS assignment_title, Students.name AS student_name, Grades.score
FROM Assignments
INNER JOIN Grades ON Assignments.assignment_id = Grades.assignment_id
INNER JOIN Students ON Grades.student_id = Students.student_id;

--List Each Course Name, the Total Number of Enrolled Students, and the Instructor's Name
SELECT Courses.course_name, COUNT(Enrollments.student_id) AS total_students, Instructors.name AS instructor_name
FROM Courses
LEFT JOIN Enrollments ON Courses.course_id = Enrollments.course_id
INNER JOIN Instructors ON Courses.course_id = Instructors.course_id
GROUP BY Courses.course_name, Instructors.name;

--Calculate the Average Attendance Rate for Each Course (Percentage of "Present" Status)
SELECT Courses.course_name,
       AVG(CASE WHEN Attendance.status = 'Present' THEN 1 ELSE 0 END) * 100 AS attendance_rate
FROM Courses
INNER JOIN Attendance ON Courses.course_id = Attendance.course_id
GROUP BY Courses.course_name;

select * from Students
