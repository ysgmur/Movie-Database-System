-- Create the database
CREATE DATABASE IF NOT EXISTS movie;
USE movie;

-- Create the Movies table
CREATE TABLE movies (
    M_ID INT PRIMARY KEY,
    M_Name VARCHAR(30),
    M_Type VARCHAR(30)
);

-- Create the Shows table
CREATE TABLE shows (
    S_ID INT PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE,
    Location VARCHAR(30),
    Language VARCHAR(30),
    M_ID INT,
    FOREIGN KEY(M_ID) REFERENCES movies(M_ID)
);

-- Create the Cards table
CREATE TABLE cards (
    Card_No INT PRIMARY KEY,
    Card_Name VARCHAR(30)
);

-- Create the Customer table
CREATE TABLE customer (
    C_ID INT PRIMARY KEY,
    C_Name VARCHAR(30),
    Email VARCHAR(30),
    Age INT NOT NULL,
    Phone VARCHAR(30),
    Card_No INT,
    FOREIGN KEY(Card_No) REFERENCES cards(Card_No)
);

-- Create the Booking table
CREATE TABLE booking (
    B_ID INT PRIMARY KEY,
    SeatCount INT,
    Booking_Date DATE,
    S_ID INT,
    C_ID INT,
    FOREIGN KEY(S_ID) REFERENCES shows(S_ID),
    FOREIGN KEY(C_ID) REFERENCES customer(C_ID)
);

-- Create the Tickets table
CREATE TABLE tickets (
    T_ID INT PRIMARY KEY,
    SeatNumber VARCHAR(20),
    Price INT,
    S_ID INT,
    C_ID INT,
    FOREIGN KEY(S_ID) REFERENCES shows(S_ID),
    FOREIGN KEY(C_ID) REFERENCES customer(C_ID)
);

-- Create the Payment table
CREATE TABLE payment (
    P_ID INT PRIMARY KEY,
    C_ID INT,
    B_ID INT,
    Card_No INT,
    FOREIGN KEY(C_ID) REFERENCES customer(C_ID),
    FOREIGN KEY(B_ID) REFERENCES booking(B_ID),
    FOREIGN KEY(Card_No) REFERENCES cards(Card_No)
);

-- Insert sample data
INSERT INTO movies VALUES
(1, 'Inception', 'Sci-Fi'),
(2, 'The Shawshank Redemption', 'Drama'),
(3, 'The Dark Knight', 'Action'),
(4, 'Pulp Fiction', 'Crime'),
(5, 'Forrest Gump', 'Drama'),
(6, 'The Matrix', 'Sci-Fi'),
(7, 'The Godfather', 'Crime');

INSERT INTO shows VALUES
(1, '2023-01-01', '2023-01-10', 'Theater 1', 'English', 1),
(2, '2023-01-01', '2023-01-10', 'Theater 2', 'Spanish', 1),
(3, '2023-02-05', '2023-02-15', 'Theater 2', 'Spanish', 2),
(4, '2023-03-10', '2023-03-20', 'Theater 3', 'French', 3),
(5, '2023-04-15', '2023-04-25', 'Theater 1', 'English', 4),
(6, '2023-05-20', '2023-05-30', 'Theater 2', 'Spanish', 5),
(7, '2023-06-01', '2023-06-10', 'Theater 1', 'English', 6),
(8, '2023-06-01', '2023-06-10', 'Theater 2', 'English', 6),
(9, '2023-07-05', '2023-07-15', 'Theater 2', 'Spanish', 7);

INSERT INTO cards VALUES
(101, 'Card X'),
(102, 'Card Y'),
(103, 'Card Z');

INSERT INTO customer VALUES
(201, 'John Doe', 'john@example.com', 25, '123-456-7890', 101),
(202, 'Jane Smith', 'jane@example.com', 30, '987-654-3210', 102),
(203, 'Bob Johnson', 'bob@example.com', 22, '555-123-4567', 103),
(204, 'Alice Brown', 'alice@example.com', 28, '111-222-3333', 101),
(205, 'Charlie Davis', 'charlie@example.com', 35, '444-555-6666', 102);

INSERT INTO booking VALUES
(301, 2, '2023-01-05', 1, 201),
(302, 3, '2023-02-08', 2, 202),
(303, 1, '2023-03-15', 3, 203),
(304, 2, '2023-02-10', 1, 204),
(305, 3, '2023-03-18', 2, 205),
(306, 2, '2023-06-05', 6, 201),
(307, 3, '2023-07-08', 7, 202);

INSERT INTO tickets VALUES
(401, 'A1', 20, 1, 201),
(402, 'B2', 25, 2, 202),
(403, 'C3', 15, 3, 203),
(404, 'D4', 20, 1, 204),
(405, 'E5', 25, 2, 205),
(406, 'F6', 30, 6, 201),
(407, 'G7', 35, 7, 202);
INSERT INTO payment VALUES
(501, 201, 301, 101),
(502, 202, 302, 102),
(503, 203, 303, 103),
(504, 204, 304, 101),
(505, 205, 305, 102),
(506, 201, 306, 102),
(507, 202, 307, 102);

-- Calculate the average ticket price for each movie genre:
SELECT m.M_Type, AVG(t.Price) AS AverageTicketPrice
FROM movies m
JOIN shows s ON m.M_ID = s.M_ID
JOIN booking b ON s.S_ID = b.S_ID
JOIN tickets t ON b.S_ID = t.S_ID AND b.C_ID = t.C_ID
GROUP BY m.M_Type;

-- Find the top 3 movies with the highest total revenue:
SELECT m.M_ID, m.M_Name, SUM(t.Price) AS TotalRevenue
FROM movies m
JOIN shows s ON m.M_ID = s.M_ID
JOIN booking b ON s.S_ID = b.S_ID
JOIN tickets t ON b.S_ID = t.S_ID AND b.C_ID = t.C_ID
GROUP BY m.M_ID, m.M_Name
ORDER BY TotalRevenue DESC
LIMIT 3;

-- movies that shows in different theater but have same language
SELECT
    m.M_Name,
    s.Language,
    s.Location AS TheaterLocation
FROM
    movies m
JOIN shows s ON
    m.M_ID = s.M_ID
WHERE
    m.M_ID IN (
        SELECT
            m_id
        FROM
            shows
        GROUP BY
            M_ID, Language
        HAVING
            COUNT(DISTINCT Location) > 1
    );

-- customers who have made payments using more than one card
SELECT c.C_ID, c.C_Name
FROM customer c
JOIN payment p ON c.C_ID = p.C_ID
GROUP BY c.C_ID, c.C_Name
HAVING COUNT(DISTINCT p.Card_No) > 1;

-- Card Usage Frequency
SELECT
    card.Card_No,
    COUNT(DISTINCT c.C_ID) AS CustomerCount
FROM
    cards card
LEFT JOIN customer c ON
    card.Card_No = c.Card_No
GROUP BY
    card.Card_No
ORDER BY
    CustomerCount DESC;

-- Movies in Theatre 1 that are not booked
SELECT M_Name
FROM movies
left JOIN shows ON movies.M_ID = shows.M_ID
left JOIN booking ON shows.S_ID = booking.S_ID
WHERE shows.Location = 'Theater 1' AND booking.B_ID IS NULL;

-- Average age of customers per movie
SELECT
    m.M_Name,
    AVG(c.Age) AS AverageAge
FROM
    movies m
JOIN shows s ON
    m.M_ID = s.M_ID
JOIN booking b ON
    s.S_ID = b.S_ID
JOIN customer c ON
    b.C_ID = c.C_ID
GROUP BY
    m.M_Name;
    
-- Number of ticket sold in each Theater
SELECT
    s.Location,
    COUNT(t.T_ID) AS TicketCount
FROM
    shows s
LEFT JOIN
    booking b ON s.S_ID = b.S_ID
LEFT JOIN
    tickets t ON b.S_ID = t.S_ID AND b.C_ID = t.C_ID
GROUP BY
    s.Location;

-- Most popular language
SELECT
    s.Language,
    COUNT(b.B_ID) AS BookingCount
FROM
    shows s
JOIN booking b ON
    s.S_ID = b.S_ID
GROUP BY
    s.Language
ORDER BY
    BookingCount DESC
LIMIT 1;

-- Customer with the Highest Total Spending
SELECT
    c.C_ID,
    c.C_Name,
    SUM(t.Price) AS TotalSpending
FROM
    customer c
JOIN
    booking b ON c.C_ID = b.C_ID
JOIN
    tickets t ON b.S_ID = t.S_ID AND b.C_ID = t.C_ID
GROUP BY
    c.C_ID, c.C_Name
HAVING
    TotalSpending >= 50
ORDER BY
    TotalSpending DESC
LIMIT 1;








