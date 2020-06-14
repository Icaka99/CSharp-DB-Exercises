USE SoftUni

GO

CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS 
BEGIN
    SELECT FirstName, LastName
    FROM Employees
    WHERE Salary > 35000
END

EXEC usp_GetEmployeesSalaryAbove35000

GO

CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber(@MinSalary DECIMAL(18,4))
AS 
BEGIN
    SELECT FirstName, LastName
    FROM Employees
    WHERE Salary >= @MinSalary
END

EXEC usp_GetEmployeesSalaryAboveNumber 48100

GO

CREATE PROCEDURE usp_GetTownsStartingWith(@StartingString NVARCHAR(MAX))
AS 
BEGIN
        SELECT [Name]
        FROM Towns
        WHERE [Name] LIKE (@StartingString + '%')
END

EXEC usp_GetTownsStartingWith 'b'

GO

CREATE PROCEDURE usp_GetEmployeesFromTown(@TownName NVARCHAR(MAX))
AS
BEGIN
    SELECT FirstName, LastName FROM Employees AS e
    JOIN Addresses AS a
    ON e.AddressID = a.AddressID
    JOIN Towns AS t 
    ON t.TownID = a.TownID
    WHERE @TownName = t.Name
END

EXEC usp_GetEmployeesFromTown 'Sofia'

GO

CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18,4))
RETURNS VARCHAR(10)
AS 
BEGIN
    DECLARE @SalaryLevel VARCHAR(10)
    IF (@Salary < 30000)
        SET @SalaryLevel = 'Low'
    ELSE IF (@Salary <= 50000)
        SET @SalaryLevel = 'Average'
    ELSE 
        SET @SalaryLevel = 'High'
    RETURN @SalaryLevel
END

GO

CREATE PROCEDURE usp_EmployeesBySalaryLevel(@LevelOfSalary VARCHAR(10))
AS 
BEGIN
    SELECT FirstName, LastName 
    FROM Employees
    WHERE dbo.ufn_GetSalaryLevel(Salary) = @LevelOfSalary
END

EXEC usp_EmployeesBySalaryLevel high

GO

CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@DepartmentId INT)
AS 
BEGIN 

    DELETE FROM EmployeesProjects
    WHERE EmployeeID IN 
    ( 
        SELECT EmployeeId
        FROM Employees
        WHERE DepartmentID = @DepartmentId
    )

    UPDATE Employees
    SET ManagerID = NULL
    WHERE ManagerID IN 
    ( 
        SELECT EmployeeId
        FROM Employees
        WHERE DepartmentID = @DepartmentId
    )

    ALTER TABLE Departments
    ALTER COLUMN ManagerID INT

    UPDATE Departments 
    SET ManagerID = NULL
    WHERE ManagerID IN
    ( 
        SELECT EmployeeId
        FROM Employees
        WHERE DepartmentID = @DepartmentId
    )

    DELETE FROM Employees
    WHERE DepartmentID = @DepartmentId

    DELETE FROM Departments
    WHERE DepartmentID = @DepartmentId

    SELECT COUNT(*) FROM Employees
    WHERE DepartmentID = @DepartmentId
END 

GO 

CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan (@MinBalance DECIMAL(18,4))
AS
BEGIN
    SELECT FirstName, LastName FROM Accounts AS a 
    JOIN AccountHolders AS ah 
    ON a.AccountHolderId = ah.Id
    GROUP BY FirstName, LastName
    HAVING SUM(Balance) > @MinBalance
    ORDER BY FirstName, LastName
END

GO 

CREATE FUNCTION ufn_CalculateFutureValue (@Sum DECIMAL(18,4), @Yir FLOAT, @YearsCount INT)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @FutureValue DECIMAL(18,4)

    SET @FutureValue = @Sum * (POWER((1 + @yir), @YearsCount)) 

    RETURN @FutureValue
END

GO

CREATE FUNCTION ufn_CashInUsersGames(@GameName NVARCHAR(50))
RETURNS TABLE 
AS 
RETURN SELECT
(
    SELECT SUM(Cash) AS [SumCash] FROM 
    (
        SELECT g.[Name],
            ug.Cash,
            ROW_NUMBER() OVER (PARTITION BY g.[Name] ORDER BY ug.Cash DESC) AS [RowNum]
        FROM Games AS g 
        JOIN UsersGames AS ug 
        ON g.Id = ug.GameId
        WHERE g.[Name] = @GameName
    ) AS [RowNumQuery]
WHERE [RowNum] % 2 <> 0
) AS [SumCash]

GO 

CREATE FUNCTION ufn_IsWordComprised(@SetOfLetters NVARCHAR(MAX), @Word NVARCHAR(MAX))
RETURNS BIT 
AS 
BEGIN
    DECLARE @i INT = 1

    WHILE(@i <= LEN(@Word))
    BEGIN
        DECLARE @CurrChar CHAR = SUBSTRING(@Word, @i, 1)
        DECLARE @CharIndex INT =  CHARINDEX(@CurrChar, @SetOfLetters)

        IF(@CharIndex = 0)
        BEGIN
            RETURN 0
        END

        SET @i = @i + 1
    END

    RETURN 1
END