DROP TABLE IF EXISTS Movie_Actors CASCADE;
DROP TABLE IF EXISTS Reservations CASCADE;
DROP TABLE IF EXISTS Screening CASCADE;
DROP TABLE IF EXISTS Movies CASCADE;
DROP TABLE IF EXISTS Directors CASCADE;
DROP TABLE IF EXISTS Actors CASCADE;
DROP TABLE IF EXISTS Budget CASCADE;
DROP TABLE IF EXISTS Cinema_Branches CASCADE;
DROP TABLE IF EXISTS Cinema CASCADE;
DROP TABLE IF EXISTS Staff CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;

CREATE TABLE Cinema (
    c_name TEXT PRIMARY KEY,
    c_description TEXT
);

CREATE TABLE Cinema_Branches (
    branch_id SERIAL PRIMARY KEY,
    branch_location TEXT,
	c_name TEXT,
	FOREIGN KEY (c_name) REFERENCES Cinema(c_name)
);

CREATE TABLE Directors (
    director_id SERIAL PRIMARY KEY,
    name TEXT,
    birthday DATE,
    nationality TEXT
);

CREATE TABLE Movies (
    movie_id SERIAL PRIMARY KEY,
    title TEXT,
    director_id SERIAL,
    genre TEXT,
    release_date DATE,
    rating REAL,
    duration INT,
    FOREIGN KEY (director_id) REFERENCES Directors(director_id)
);

CREATE TABLE Actors (
    actor_id SERIAL PRIMARY KEY,
    name TEXT,
    birthday TEXT,
    gender CHAR,
    nationality TEXT
);

CREATE TABLE Movie_Actors (
    movie_id SERIAL,
    actor_id SERIAL,
    role TEXT,
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (actor_id) REFERENCES Actors(actor_id)
);

CREATE TABLE Screening (
    screening_id SERIAL PRIMARY KEY,
    hall_name TEXT,
    screening_time TIME,
    screening_date DATE,
    movie_id SERIAL,
    c_name TEXT,
    FOREIGN KEY (c_name) REFERENCES Cinema(c_name),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
);

CREATE TABLE Customer (
    email TEXT PRIMARY KEY,
    phone_number TEXT,
    full_name TEXT
);

CREATE TABLE Reservations (
    reservation_id SERIAL PRIMARY KEY,
    screening_id INTEGER,
    email TEXT,
    price INTEGER,
    availability BOOLEAN,
    seat_number INTEGER,
    reservation_date DATE,
    reservation_time TIME,
    FOREIGN KEY (screening_id) REFERENCES Screening(screening_id),
    FOREIGN KEY (email) REFERENCES Customer(email)
);

CREATE TABLE Budget (
    budget_id SERIAL PRIMARY KEY,
    staff_salary INTEGER,
    ticket_revenue INTEGER,
    movie_cost INTEGER,
    rent INTEGER,
    consession_revenue INTEGER,
    c_name TEXT,
    FOREIGN KEY (c_name) REFERENCES Cinema(c_name)
);

CREATE TABLE Staff (
    staff_id SERIAL PRIMARY KEY,
    position TEXT,
    full_name TEXT,
    email TEXT,
    salary INTEGER,
	branch_id SERIAL,
	FOREIGN KEY (branch_id) REFERENCES Cinema_Branches(branch_id)
);
