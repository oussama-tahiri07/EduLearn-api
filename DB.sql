	-- Db name : LMS
	
	-- Create enum types
	CREATE TYPE role_enum AS ENUM ('ADMIN', 'INSTRUCTOR', 'STUDENT');
	CREATE TYPE question_type_enum AS ENUM ('MCQ', 'ESSAY', 'TF');
	
	-- User table (combined for all roles)
	CREATE TABLE users (
	    user_id SERIAL PRIMARY KEY,
	    name VARCHAR(255) NOT NULL,
	    email VARCHAR(255) NOT NULL UNIQUE,
	    role role_enum NOT NULL,
	    password VARCHAR(255)
	);
	
	-- Course table
	CREATE TABLE course (
	    course_id SERIAL PRIMARY KEY,
	    name VARCHAR(255) NOT NULL UNIQUE,
	    description TEXT NOT NULL,
	    duration FLOAT NOT NULL,
	    instructor_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL
	);
	
	-- Quiz table
	CREATE TABLE quiz (
	    quiz_id SERIAL PRIMARY KEY,
	    quiz_title VARCHAR(255) NOT NULL UNIQUE,
	    quiz_duration TIME,
	    course_id INTEGER REFERENCES course(course_id) ON DELETE CASCADE
	);
	
	-- Question table
	CREATE TABLE question (
	    question_id SERIAL PRIMARY KEY,
	    type question_type_enum NOT NULL,
	    content TEXT NOT NULL,
	    correct_answer TEXT,
	    course_id INTEGER NOT NULL REFERENCES course(course_id) ON DELETE CASCADE
	);
	
	-- Choice table
	CREATE TABLE choice (
	    choice_id SERIAL PRIMARY KEY,
	    value VARCHAR(255) NOT NULL,
	    question_id INTEGER NOT NULL REFERENCES question(question_id) ON DELETE CASCADE
	);
	
	-- Quiz Submission table
	CREATE TABLE quiz_submission (
	    submission_id SERIAL PRIMARY KEY,
	    grade INTEGER,
	    quiz_id INTEGER REFERENCES quiz(quiz_id) ON DELETE CASCADE,
	    student_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE
	);
	
	-- Submitted Question table (for answers to questions)
	CREATE TABLE submitted_question (
	    submitted_question_id SERIAL PRIMARY KEY,
	    student_answer TEXT NOT NULL,
	    question_id INTEGER NOT NULL REFERENCES question(question_id) ON DELETE CASCADE,
	    submission_id INTEGER NOT NULL REFERENCES quiz_submission(submission_id) ON DELETE CASCADE
	);
	
	-- Junction table for Question-Quiz Submission many-to-many relationship
	CREATE TABLE question_submission (
	    question_id INTEGER REFERENCES question(question_id) ON DELETE CASCADE,
	    submission_id INTEGER REFERENCES quiz_submission(submission_id) ON DELETE CASCADE,
	    PRIMARY KEY (question_id, submission_id)
	);
	
	-- Lesson table
	CREATE TABLE lesson (
	    lesson_id SERIAL PRIMARY KEY,
	    title VARCHAR(255) NOT NULL,
	    description TEXT,
	    course_id INTEGER REFERENCES course(course_id) ON DELETE CASCADE
	);
	
	-- Lesson OTP table
	CREATE TABLE lesson_otp (
	    id SERIAL PRIMARY KEY,
	    otp_value INTEGER NOT NULL,
	    expire_at TIMESTAMP NOT NULL,
	    lesson_id INTEGER UNIQUE REFERENCES lesson(lesson_id) ON DELETE CASCADE
	);
	
	-- Lesson Resource table
	CREATE TABLE lesson_resource (
	    resource_id SERIAL PRIMARY KEY,
	    file_name VARCHAR(255) NOT NULL,
	    file_type VARCHAR(255) NOT NULL,
	    lesson_id INTEGER NOT NULL REFERENCES lesson(lesson_id) ON DELETE CASCADE
	);
	
	-- Assignment table
	CREATE TABLE assignment (
	    assignment_id SERIAL PRIMARY KEY,
	    title VARCHAR(255) NOT NULL,
	    description TEXT,
	    due_date TIMESTAMP,
	    course_id INTEGER NOT NULL REFERENCES course(course_id) ON DELETE CASCADE
	);
	
	-- Assignment Submission table
	CREATE TABLE assignment_submissions (
	    submission_id SERIAL PRIMARY KEY,
	    assignment_id INTEGER REFERENCES assignment(assignment_id) ON DELETE SET NULL,
	    student_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
	    file_name VARCHAR(255),
	    file_type VARCHAR(255),
	    file_path VARCHAR(255),
	    grade INTEGER DEFAULT 0,
	    is_graded BOOLEAN DEFAULT FALSE,
	    submission_date TIMESTAMP
	);
	
	-- Notification table
	CREATE TABLE notification (
	    id SERIAL PRIMARY KEY,
	    message TEXT NOT NULL,
	    time TIMESTAMP NOT NULL,
	    is_read BOOLEAN NOT NULL,
	    student_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
	    instructor_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE
	);
	
	-- Junction tables for many-to-many relationships
	
	-- Enrolled students (Course-Student relationship)
	CREATE TABLE enrolled_students (
	    course_id INTEGER REFERENCES course(course_id) ON DELETE CASCADE,
	    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
	    PRIMARY KEY (course_id, user_id)
	);
	
	-- Lesson attendance (Lesson-Student relationship)
	CREATE TABLE lesson_attendance (
	    lesson_id INTEGER REFERENCES lesson(lesson_id) ON DELETE CASCADE,
	    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
	    PRIMARY KEY (lesson_id, user_id)
	);
	
	-- Create indexes for better performance
	
	-- Course indexes
	CREATE INDEX idx_course_instructor ON course(instructor_id);
	
	-- Lesson indexes
	CREATE INDEX idx_lesson_course ON lesson(course_id);
	
	-- Assignment indexes
	CREATE INDEX idx_assignment_course ON assignment(course_id);
	CREATE INDEX idx_assignment_submission_assignment ON assignment_submissions(assignment_id);
	CREATE INDEX idx_assignment_submission_student ON assignment_submissions(student_id);
	
	-- Question indexes
	CREATE INDEX idx_question_course ON question(course_id);
	CREATE INDEX idx_choice_question ON choice(question_id);
	
	-- Notification indexes
	CREATE INDEX idx_notification_student ON notification(student_id);
	CREATE INDEX idx_notification_instructor ON notification(instructor_id);
	
	-- Quiz indexes
	CREATE INDEX idx_quiz_course ON quiz(course_id);
	CREATE INDEX idx_quiz_submission_quiz ON quiz_submission(quiz_id);
	CREATE INDEX idx_quiz_submission_student ON quiz_submission(student_id);
	
	-- Submitted question indexes
	CREATE INDEX idx_submitted_question_question ON submitted_question(question_id);
	CREATE INDEX idx_submitted_question_submission ON submitted_question(submission_id);
	
	-- Student-specific indexes (for performance optimization)
	CREATE INDEX idx_student_notifications ON notification(student_id) WHERE student_id IS NOT NULL;
	CREATE INDEX idx_student_assignments ON assignment_submissions(student_id);
	CREATE INDEX idx_student_quiz_submissions ON quiz_submission(student_id);