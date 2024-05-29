--1. View the movies currently on screen
SELECT m.title as movie_title, d.name as director_name
FROM Movies m
JOIN Directors d ON m.director_id = d.director_id
JOIN Screening s ON m.movie_id = s.movie_id;


--2. Insert new movies
INSERT INTO Movies VALUES (1021, 'Dumb and Dumber', 406, 'Comedy', '2003-11-02', 8.5, 123);

SELECT *
FROM Movies
WHERE Movies.title = 'Dumb and Dumber';


--3. Give the screenings of the specific day
CREATE OR REPLACE FUNCTION get_screenings_for_date(screen_date DATE)
RETURNS TABLE(screening_id INTEGER, hall_name TEXT, screening_time TIME, movie_id INTEGER, c_name TEXT) AS $$
BEGIN
    RETURN QUERY 
    SELECT s.screening_id, s.hall_name, s.screening_time, s.movie_id, s.c_name
    FROM Screening s
    WHERE s.screening_date = screen_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_screenings_for_date('2024-05-01');


--4. Check availability and reserve the seats
--Reservation function
CREATE OR REPLACE FUNCTION reserve(email TEXT, screening_id INT, seat_number INT)
    RETURNS VOID
AS
$$
DECLARE
    new_res_id INT;
BEGIN
    INSERT INTO Reservations (screening_id, email, reservation_date, reservation_time, seat_number, availability, price)
    VALUES (screening_id, email, CURRENT_DATE, CURRENT_TIME, seat_number, TRUE, 10)  -- assuming price is static, adjust as needed
    RETURNING reservation_id INTO new_res_id;

    UPDATE Reservations
    SET availability = TRUE
    WHERE reservation_id = new_res_id;
END;
$$ LANGUAGE 'plpgsql';

SELECT reserve('petersonjason@example.net', 10001, 3);
SELECT * FROM Reservations
WHERE seat_number ='3';

--Check seat availablity function
CREATE OR REPLACE FUNCTION check_seat_availability()
    RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Reservations
        WHERE screening_id = NEW.screening_id
          AND seat_number = NEW.seat_number
          AND availability = TRUE
    ) THEN
        RAISE EXCEPTION 'This seat is already reserved.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_check_seat_before_insert
BEFORE INSERT ON Reservations
FOR EACH ROW
EXECUTE FUNCTION check_seat_availability();


SELECT reserve('gwilliams@example.net', 10001, 3);


--5.Updates staff information like the salary and position
CREATE OR REPLACE FUNCTION update_staff_info_full(staff_id INTEGER, new_position TEXT, new_salary INTEGER, new_email TEXT, new_branch_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE Staff s
    SET position = new_position,
        salary = new_salary,
        email = new_email,
        branch_id = new_branch_id
    WHERE s.staff_id = update_staff_info_full.staff_id;
END;
$$ LANGUAGE plpgsql;

SELECT update_staff_info_full(4025, 'Senior Animator', 98000, 'animator@example.com', 2);
SELECT * FROM Staff WHERE staff_id = 4025;


--6.Monthly Financial Summary
SELECT EXTRACT(MONTH FROM screening_date) AS month, SUM(price) AS total_income, SUM(staff_salary) AS total_salaries
FROM Screening
JOIN Reservations USING (screening_id)
JOIN Budget USING (c_name)
GROUP BY month;


--7.Calculate annual revenue
SELECT c_name,
SUM(ticket_revenue + consession_revenue - staff_salary - movie_cost - rent) AS net_profit
FROM Budget
GROUP BY c_name;


--8.Here we calculate the number of distinct films in the cinema
SELECT COUNT(DISTINCT title) AS number_of_films
FROM Movies;
-- Here is the calculation of each movies ticket sales and the 0 sales ones are not shown
SELECT m.title, SUM(r.price) AS total_revenue
FROM Movies m
JOIN Screening s ON m.movie_id = s.movie_id
JOIN Reservations r ON s.screening_id = r.screening_id
GROUP BY m.title
ORDER BY total_revenue DESC;


--9.Give highest ranking movie among all shown movie
CREATE OR REPLACE FUNCTION highest_ranking_movie()
    RETURNS TABLE
            (
                title       TEXT,
                rating      REAL
            )
AS
$$
BEGIN
    RETURN QUERY SELECT m.title, m.rating
                 FROM Movies m
                 ORDER BY m.rating DESC
                 LIMIT 1;
END;
$$ LANGUAGE 'plpgsql';
SELECT * FROM highest_ranking_movie();


--10.Most Popular Movies by Tickets Sold
SELECT m.title, COUNT(*) AS tickets_sold
FROM Reservations r
JOIN Screening s ON r.screening_id = s.screening_id
JOIN Movies m ON s.movie_id = m.movie_id
GROUP BY m.title
ORDER BY tickets_sold DESC;

--11.Find top customers by reservation count
SELECT r.email, c.full_name, COUNT(r.reservation_id) AS num_reservations
FROM Reservations r
JOIN Customer c ON r.email = c.email
GROUP BY r.email, c.full_name
ORDER BY num_reservations DESC
LIMIT 10;

--12. Actor Popularity Analysis
SELECT a.name, COUNT(*) AS num_movies
FROM Actors a
JOIN Movie_Actors ma ON a.actor_id = ma.actor_id
GROUP BY a.name
ORDER BY num_movies DESC;

--13.Count the number of reservations made for each screening in each cinema hall
SELECT s.hall_name, s.screening_date, COUNT(r.reservation_id) AS num_reservations
FROM Screening s
LEFT JOIN Reservations r ON s.screening_id = r.screening_id
GROUP BY s.hall_name, s.screening_date
ORDER BY num_reservations DESC;

--14.Identify customers who have not made reservations in the last month
SELECT email, full_name
FROM Customer
WHERE email NOT IN (
    SELECT DISTINCT email
    FROM Reservations
    WHERE reservation_date >= CURRENT_DATE - INTERVAL '1 month'
);

--15. Returns the list of movies in which a specific actor has appeared.
SELECT m.title AS movie_title, m.release_date
FROM Movies m
JOIN Movie_Actors ma ON m.movie_id = ma.movie_id
JOIN Actors a ON ma.actor_id = a.actor_id
WHERE a.name = 'George Crawford';

