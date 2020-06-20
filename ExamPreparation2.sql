CREATE DATABASE [Service]

USE [Service]

--Exercise 1.DDL

CREATE TABLE Users(
    Id INT PRIMARY KEY IDENTITY,
    Username VARCHAR(30) NOT NULL UNIQUE,
    [Password] VARCHAR(50) NOT NULL,
    [Name] VARCHAR(50),
    Birthdate DATETIME2,
    Age INT CHECK(Age >= 14 AND Age <= 110),
    Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
    Id INT PRIMARY KEY IDENTITY,
    [Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
    Id INT PRIMARY KEY IDENTITY,
    FirstName VARCHAR(25),
    LastName VARCHAR(25),
    Birthdate DATETIME2,
    Age INT CHECK(Age >= 18 AND Age <= 110),
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories(
    Id INT PRIMARY KEY IDENTITY,
    [Name] VARCHAR(50) NOT NULL,
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE [Status](
    Id INT PRIMARY KEY IDENTITY,
    Label VARCHAR(30) NOT NULL
)

CREATE TABLE Reports(
    Id INT PRIMARY KEY IDENTITY,
    CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
    StatusId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
    OpenDate DATETIME2 NOT NULL,
    CloseDate DATETIME2,
    [Description] VARCHAR(200) NOT NULL,
    UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
    EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

DROP DATABASE [Service]

--Exercise 2.DML-Insert

INSERT INTO Employees(FirstName, LastName, Birthdate, DepartmentId)
    VALUES
        ('Marlo', 'O''Malley', '1958-9-21', 1),
        ('Niki', 'Stanaghan', '1969-11-26', 4),
        ('Ayrton', 'Senna', '1960-03-21', 9),
        ('Ronnie', 'Peterson', '1944-02-14', 9),
        ('Giovanna', 'Amati', '1959-07-20', 5)

INSERT INTO Reports(CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId)
    VALUES
        (1, 1, '2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2),
        (6, 3, '2015-09-05', '2015-12-06', 'Charity trail running', 3, 5),
        (14, 2, '2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2),
        (4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1)

--Exercise 3.DML-Update

UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

--ECERCISE 4.DML-Delete

DELETE Reports
WHERE StatusId = 4

--Exercise 5.Unassigned Reports

SELECT [Description],
    FORMAT(OpenDate, 'dd-MM-yyyy') AS OpenDate
FROM Reports AS r
WHERE EmployeeId IS NULL
ORDER BY r.OpenDate, [Description]

--Exercise 6.Reports & Categories

SELECT r.[Description], c.Name 
FROM Reports AS r
JOIN Categories AS c
ON r.CategoryId = c.Id
ORDER BY r.[Description], c.Name

--Exercise 7.Most Reported Category

SELECT TOP(5) c.Name, 
COUNT(*) AS ReportsNumber
FROM Reports AS r
JOIN Categories AS c
ON r.CategoryId = c.Id
GROUP BY c.Name
ORDER BY ReportsNumber DESC, c.Name

--Exercise 8.Birthday Report

SELECT u.Username, c.Name 
FROM Users AS u
JOIN Reports AS r
ON u.Id = r.UserId
JOIN Categories AS c 
ON c.Id = r.CategoryId
WHERE DATEPART(MONTH, r.OpenDate) = DATEPART(MONTH, u.Birthdate)
    AND DATEPART(DAY, r.OpenDate) = DATEPART(DAY, u.Birthdate)
ORDER BY u.Username, c.Name


--Exercise 9.Users per Employee


SELECT CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
COUNT(UserId) AS UsersCount
FROM Employees AS e
LEFT JOIN Reports AS r
ON e.Id = r.EmployeeId
LEFT JOIN Users AS u 
ON r.UserId = u.Id
GROUP BY e.Id, FirstName, LastName
ORDER BY UsersCount DESC, FullName

--Exercise 10.FullInfo

SELECT ISNULL(e.FirstName + ' ' + e.LastName, 'None') AS Employee,
    ISNULL(d.Name, 'None') AS Department,
    c.Name AS Category,
    r.[Description],
    FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate,
    s.Label AS [Status],
    u.Name AS [User]
FROM Reports AS r 
LEFT JOIN Categories AS c 
ON r.CategoryId = c.Id
LEFT JOIN Employees AS e 
ON e.Id = r.EmployeeId
LEFT JOIN Departments AS d 
ON e.DepartmentId = d.Id
LEFT JOIN [Status] AS s 
ON s.Id = r.StatusId
LEFT JOIN Users AS u 
ON u.Id = r.UserId
ORDER BY e.FirstName DESC, e.LastName DESC, d.Name, c.Name, r.[Description], 
r.OpenDate, s.Label, u.Name

--Exercise 11.Hours to Complete
GO

CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN
    IF (@StartDate IS NULL)
    RETURN 0;
    IF(@EndDate IS NULL)
    RETURN 0;

    DECLARE @HoursDiff INT = DATEDIFF(HOUR, @StartDate, @EndDate);
    RETURN @HoursDiff
END

--Exercise 12.Assign Employee

GO
CREATE PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN
    DECLARE @EmployeeDepartmentId INT = (SELECT DepartmentId FROM Employees
        WHERE  Id = @EmployeeId);

    DECLARE @ReportDepartmentId INT = 
    (SELECT c.DepartmentId
    FROM Reports AS r 
    JOIN Categories AS c 
    ON c.Id = r.CategoryId
    WHERE r.Id = @ReportId)

    IF(@EmployeeDepartmentId != @ReportDepartmentId)
    THROW 50000, 'Employee doesn''t belong to the appropriate department!', 1

    UPDATE Reports
    SET EmployeeId = @EmployeeId
    WHERE Id = @ReportId
END