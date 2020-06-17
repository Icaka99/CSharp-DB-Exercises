CREATE DATABASE Airport

USE Airport

--Exercise 1.Database Design

CREATE TABLE Planes (
    Id INT PRIMARY KEY IDENTITY,
    [Name] VARCHAR(30) NOT NULL,
    Seats INT NOT NULL,
    [Range] INT NOT NULL
)

CREATE TABLE Flights (
    Id INT PRIMARY KEY IDENTITY,
    DepartureTime DATETIME2,
    ArrivalTime DATETIME2,
    Origin VARCHAR(50) NOT NULL,
    Destination VARCHAR(50) NOT NULL,
    PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)

CREATE TABLE Passengers (
    Id INT PRIMARY KEY IDENTITY,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    Age INT NOT NULL,
    [Address] VARCHAR(30) NOT NULL,
    PassportId CHAR(11) NOT NULL
)

CREATE TABLE LuggageTypes (
    Id INT PRIMARY KEY IDENTITY,
    [Type] VARCHAR(30) NOT NULL
)

CREATE TABLE Luggages (
    Id INT PRIMARY KEY IDENTITY,
    LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
    PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
)

CREATE TABLE Tickets (
    Id INT PRIMARY KEY IDENTITY,
    PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
    FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
    LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
    Price DECIMAL(18,2) NOT NULL
)

-- Exercise 2.DML(Insert)

INSERT INTO Planes ([Name], Seats, [Range])
    VALUES
        ('Airbus 336', 112, 5132),
        ('Airbus 330', 432, 5325),
        ('Boeing 369', 231, 2355),
        ('Stelt 297', 254, 2143),
        ('Boeing 338', 165, 5111),
        ('Airbus 558', 387, 1342),
        ('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes ([Type])
    VALUES 
        ('Crossbody Bag'),
        ('School Backpack'),
        ('Shoulder Bag')

-- Exercise 3.DML(Update)

UPDATE Tickets
SET Price += Price * 0.13
WHERE FlightId = (SELECT TOP(1) Id FROM Flights WHERE Destination = 'Carlsbad')

-- Exercise 4.DML(Delet)

DELETE FROM Tickets
WHERE FlightId = (SELECT Id FROM Flights WHERE Destination = 'Ayn Halagim')

DELETE FROM Flights
WHERE Destination = 'Ayn Halagim'

-- Exercise 5.The "Tr" Planes

SELECT * FROM Planes
WHERE [Name] LIKE '%tr%'
ORDER BY Id, [Name], Seats, [Range]

-- Exercise 6.Flight Profits

SELECT FlightId, SUM(Price) AS [Price] FROM Tickets 
GROUP BY FlightId
ORDER BY [Price] DESC, FlightId

-- Exercise 7.PassengerTrips

SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name],
       f.Origin,
       f.Destination 
FROM Passengers AS p
JOIN Tickets AS t
ON p.Id = t.PassengerId
JOIN Flights AS f 
ON t.FlightId = f.Id
ORDER BY [Full Name], f.Origin, f.Destination

-- Exercise 8.NonAdventures People

SELECT * FROM Passengers

SELECT FirstName, LastName, Age FROM Passengers AS p
LEFT JOIN Tickets AS t
ON p.Id = t.PassengerId
WHERE t.FlightId IS NULL
ORDER BY Age DESC, FirstName, LastName

--Exercise 9.FullInfo

SELECT CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name],
       pl.Name AS [Plane Name],
       CONCAT(f.Origin, ' - ', f.Destination) AS [Trip],
       lt.[Type] AS [LuggageType]
FROM Passengers AS p
JOIN Tickets AS t 
ON p.Id = t.PassengerId
JOIN Flights AS f 
ON t.FlightId = f.Id
JOIN Planes AS pl 
ON f.PlaneId = pl.Id
JOIN Luggages AS l 
ON t.LuggageId = l.Id
JOIN LuggageTypes AS lt 
ON l.LuggageTypeId = lt.Id
ORDER BY [Full Name], [Plane Name], f.Origin, f.Destination, [LuggageType]

-- Exercise 10.PSP

SELECT p.Name, p.Seats , COUNT(t.Id) AS [Passenger Count]  FROM Planes AS p
LEFT JOIN Flights AS f
ON p.Id = f.PlaneId
LEFT JOIN Tickets AS t 
ON f.Id = t.FlightId
GROUP BY p.Name, p.Seats
ORDER BY [Passenger Count] DESC, p.Name, p.Seats

-- Exercise 11.Vacation

GO

CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT) 
RETURNS VARCHAR(100)
AS 
BEGIN
    IF (@peopleCount <= 0)
    RETURN 'Invalid people count!'

    DECLARE @tripId INT =
    (
        SELECT f.Id FROM Flights AS f 
        JOIN Tickets AS t 
        ON t.FlightId = f.Id
        WHERE Destination = @destination AND @origin = Origin
    )

    IF (@tripId IS NULL)
    RETURN 'Invalid flight!'

    DECLARE @ticketPrice DECIMAL(18,2) = 
    (
        SELECT t.Price FROM Flights AS f 
        JOIN Tickets AS t 
        ON t.FlightId = f.Id
        WHERE Destination = @destination AND Origin = @origin
    )

    DECLARE @totalPrice DECIMAL(18,2) = @ticketPrice * @peopleCount

    RETURN 'Total price ' + CAST(@totalPrice as VARCHAR(30));
        
END

-- Execise 12.WrongData

GO

CREATE PROC usp_CancelFlights
AS 
BEGIN 
    UPDATE Flights
    SET DepartureTime = NULL, ArrivalTime = NULL
    WHERE DepartureTime < ArrivalTime
END

EXEC usp_CancelFlights