CREATE DATABASE TripService

USE TripService

CREATE TABLE Cities (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(20) NOT NULL,
    CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(30) NOT NULL,
    CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
    EmployeeCount INT NOT NULL,
    BaseRate DECIMAL(15,2)
)

CREATE TABLE Rooms (
    Id INT PRIMARY KEY IDENTITY,
    Price DECIMAL(15,2) NOT NULL,
    [Type] NVARCHAR(20) NOT NULL,
    Beds INT NOT NULL,
    HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips (
    Id INT PRIMARY KEY IDENTITY,
    RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
    BookDate DATE NOT NULL,
    ArrivalDate DATE NOT NULL,
    ReturnDate DATE NOT NULL,
    CancelDate DATE,
    CHECK(BookDate < ArrivalDate),
    CHECK(ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts (
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(20),
    LastName NVARCHAR(50) NOT NULL,
    CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
    BirthDate DATE NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips (
    AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
    TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
    Luggage INT NOT NULL CHECK(Luggage >= 0),
    PRIMARY KEY(AccountId, TripId)
)

INSERT INTO Accounts (FirstName, MiddleName, LastName, CityId, BirthDate, Email)
    VALUES
        ('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
        ('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
        ('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@gmail.com'),
        ('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@gmail.com')

INSERT INTO Trips (RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
    VALUES
        (101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
        (102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
        (103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
        (104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
        (109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)

--Exercise 3.Update

UPDATE Rooms
SET Price = Price * 1.14
WHERE HotelId IN (5, 7, 9)

--Exercise 4.Delete

DELETE AccountsTrips
WHERE AccountId = 47

--Exercise 5.EEE-Mails

SELECT FirstName,
    LastName, 
    FORMAT(BirthDate, 'MM-dd-yyyy') AS BirthDate,
    c.Name AS Hometown,
    a.Email
FROM Accounts AS a
JOIN Cities AS c 
ON a.CityId = c.ID
WHERE Email LIKE 'e%'
ORDER BY c.Name

--Exercise 6.City Statistics

SELECT c.Name, COUNT(h.Id) AS Hotels 
FROM Cities AS c 
JOIN Hotels AS h 
ON c.ID = h.CityId
GROUP BY c.Name
ORDER BY Hotels DESC, c.Name

--Exercise 7.Longest and Shortest Trips

SELECT DISTINCT
a.Id AS AccountId,
CONCAT(a.FirstName, ' ', a.LastName) AS FullName,
(
    SELECT TOP(1) DATEDIFF(DAY, ArrivalDate, ReturnDate) AS LongestTrip
    FROM Trips WHERE Id = [at].[TripId]
    ORDER BY LongestTrip DESC
) AS LongestTrip,
(
    SELECT TOP(1) DATEDIFF(DAY, ArrivalDate, ReturnDate) AS ShortestTrip
FROM Trips
ORDER BY ShortestTrip
) AS ShortestTrip 
FROM Accounts AS a 
JOIN AccountsTrips AS [at]
ON a.Id = [at].AccountId
JOIN Trips AS t 
ON [at].[TripId] = t.Id 
WHERE MiddleName IS NULL AND CancelDate IS NULL
GROUP BY a.Id, a.FirstName, a.LastName, [at].TripId
ORDER BY LongestTrip DESC, ShortestTrip

--Exercise 8.Metropolis WARNING!! c.I(D)

SELECT TOP(10) c.Id,
    c.Name AS City,
    c.CountryCode AS Country,
    COUNT(a.Id) AS Accounts
FROM Cities AS c 
JOIN Accounts AS a 
ON c.Id = a.CityId
GROUP BY c.Id, c.Name, c.CountryCode
ORDER BY Accounts DESC

--Exercise 9.Romantic Getaways

SELECT a.Id,
    a.Email,
    c.Name AS City,
    COUNT([at].TripId) AS Trips
FROM Accounts AS a 
JOIN Cities AS c 
ON a.CityId = c.ID
JOIN Hotels AS h 
ON h.CityId = c.ID
JOIN AccountsTrips AS [at]
ON [at].AccountId = a.Id
JOIN Rooms AS r 
ON r.HotelId = h.Id
JOIN Trips AS t 
ON r.Id = t.RoomId AND t.Id = [at].[TripId]
WHERE a.CityId = h.CityId
GROUP BY a.Id, a.Email, c.Name
ORDER BY Trips DESC, a.Id

--Exercise 10.GDPR Violation

SELECT t.Id,
    CONCAT(a.FirstName, ' ', ISNULL(a.MiddleName + ' ', ''),  a.LastName) AS [Full Name],
    (SELECT ca.Name FROM Cities AS ca WHERE a.CityId = ca.ID) AS [From],
    (SELECT ch.Name FROM Cities AS ch WHERE h.CityId = ch.ID) AS [To],
    CASE 
        WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
        ELSE CONCAT(CAST(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate) AS NVARCHAR(MAX)), ' ', 'days')
    END AS Duration
FROM Trips AS t 
JOIN AccountsTrips AS [at]
ON t.Id = [at].[TripId]
JOIN Accounts AS a 
ON a.Id = [at].[AccountId]
JOIN Rooms AS r 
ON r.Id = t.RoomId
JOIN Hotels AS h 
ON r.HotelId = h.Id
JOIN Cities AS c 
ON h.CityId = c.ID
ORDER BY [Full Name], t.Id

--Exercise 11.Available Room - doesn't work..

GO
CREATE OR ALTER FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS NVARCHAR(MAX) 
AS
BEGIN
    DECLARE @HotelBaseRate DECIMAL(15, 2) = (SELECT TOP(1) h.BaseRate FROM Hotels AS h WHERE h.Id = @HotelId);
    DECLARE @RoomPrice DECIMAL(15, 2) = (SELECT TOP(1) Price FROM Rooms AS r WHERE r.HotelId = @HotelId);
    DECLARE @TotalPrice DECIMAL(15,2) = (@HotelBaseRate + @RoomPrice) * @People;
    -- DECLARE @ArrivalDates DATE = 
    -- (
    --     SELECT t.ArrivalDate 
    --     FROM Trips AS t
    --     JOIN Rooms AS r 
    --     ON r.Id = t.RoomId
    --     WHERE r.HotelId = @HotelId
    -- )
    -- DECLARE @ReturnDates DATE = 
    -- (
    --     SELECT t.ReturnDate 
    --     FROM Trips AS t
    --     JOIN Rooms AS r 
    --     ON r.Id = t.RoomId
    --     WHERE r.HotelId = @HotelId
    -- )
    -- DECLARE @CancelDates DATE = 
    -- (
    --     SELECT t.CancelDate 
    --     FROM Trips AS t
    --     JOIN Rooms AS r 
    --     ON r.Id = t.RoomId
    --     WHERE r.HotelId = @HotelId
    -- )
    
    -- IF((@Date BETWEEN @ArrivalDates AND @ReturnDates) AND @CancelDates IS NOT NULL)
    -- RETURN 'No rooms available'

    DECLARE @RoomId INT =
    (
        SELECT TOP(1) r.Id FROM Rooms AS r 
        JOIN Trips AS t 
        ON r.Id = t.RoomId
        WHERE HotelId = @HotelId 
        AND @Date < t.ArrivalDate 
        AND @Date > t.ReturnDate 
        AND t.CancelDate IS NOT NULL
        AND r.Beds > @People
        ORDER BY 
        (
            SELECT (r.Price * h.BaseRate) FROM Rooms AS r 
            JOIN Hotels AS h 
            ON r.HotelId = h.Id
            WHERE h.Id = @HotelId
        )
    )

    DECLARE @RoomType NVARCHAR(MAX) =
    (
        SELECT [Type] FROM Rooms
        WHERE Id = @RoomId
    )

    DECLARE @RoomBeds NVARCHAR(MAX) =
    (
        SELECT Beds FROM Rooms
        WHERE Id = @RoomId
    )

    IF(@RoomId IS NULL)
    RETURN 'No rooms available'

    RETURN CONCAT('Room ', @RoomId, ': ', @RoomType, ' (', @RoomBeds, ' beds) - ${', @TotalPrice, '}')


END

GO

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)

SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)

--Exercise 12.Switch Room

GO
CREATE OR ALTER PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS 
BEGIN
    DECLARE @TRHotelId INT = 
    (
        SELECT HotelId FROM Rooms
        WHERE @TargetRoomId = Id
    )
    DECLARE @THotelId INT = 
    (
        SELECT r.HotelId FROM Rooms AS r 
        JOIN Trips AS t 
        ON r.Id = t.RoomId
        WHERE t.Id = @TripId
    )
    IF (@TRHotelId != @THotelId)
    THROW 50000, 'Target room is in another hotel!', 1

    DECLARE @TripAccounts INT =
    (
        SELECT TOP(1) COUNT(a.Id) AS [Count] FROM Accounts AS a 
        JOIN AccountsTrips AS [at]
        ON a.Id = [at].[AccountId]
        WHERE [at].TripId = @TripId
        GROUP BY [at].[TripId]
        ORDER BY [Count]
    )
    DECLARE @TargetRoomBeds INT =
    (
        SELECT Beds FROM Rooms
        WHERE Id = @TargetRoomId
    )
    
    IF(@TripAccounts > @TargetRoomBeds)
    THROW 50001, 'Not enough beds in target room!', 1

    DECLARE @TripRoomId INT =
    (
        SELECT RoomId FROM Trips
        WHERE Id = @TripId
    )

    ALTER TABLE Rooms DROP CONSTRAINT PK_Rooms_3214EC0702D80325

    UPDATE Rooms
    SET Id = @TargetRoomId
    WHERE Id = @TripRoomId
END 

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10

EXEC usp_SwitchRoom 10, 7

EXEC usp_SwitchRoom 10, 8
