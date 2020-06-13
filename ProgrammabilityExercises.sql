SELECT TOP(5) e.EmployeeId, e.JobTitle, e.AddressId, a.AddressText 
FROM Employees AS e
JOIN Addresses AS a 
ON e.AddressID = a.AddressID
ORDER BY e.AddressID ASC

SELECT TOP(50) e.FirstName, e.LastName, t.Name AS [Town], a.AddressText FROM Employees AS e
JOIN Addresses AS a
ON e.AddressID = a.AddressID
JOIN Towns AS t 
ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName 

SELECT TOP(3) e.EmployeeID, e.FirstName FROM Employees AS e 
LEFT OUTER JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID 
WHERE ep.ProjectID IS NULL
ORDER BY e.EmployeeID

SELECT TOP(5) e.EmployeeID, e.FirstName, p.[Name] AS [ProjectName]
FROM Employees AS e 
JOIN EmployeesProjects as ep 
ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p 
ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '08.13.2002' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

SELECT e.EmployeeID, e.FirstName,
    CASE WHEN DATEPART(YEAR, p.StartDate) >= 2005 THEN NULL
    ELSE p.[Name]
END AS [ProjectName]
 FROM Employees AS e 
JOIN EmployeesProjects AS ep 
ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p 
ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24

SELECT TOP(50) e1.EmployeeID, 
    CONCAT(e1.FirstName, ' ', e1.LastName) AS [EmployeeName], 
    CONCAT(e2.FirstName, ' ', e2.LastName) AS [ManagerName],
    d.[Name] AS [DepartmentName]
FROM Employees AS e1
LEFT OUTER JOIN Employees AS e2
ON e1.ManagerID = e2.EmployeeID
JOIN Departments AS d 
ON e1.DepartmentID = d.DepartmentID 
ORDER BY e1.EmployeeID

SELECT MIN([Average Salary]) AS [MinAverage Salary] FROM 
    (SELECT DepartmentID, AVG(Salary) AS [Average Salary] FROM Employees
    GROUP BY DepartmentID) 
AS [AverageSalaryQuery]

SELECT c.CountryCode,
       m.MountainRange,
       p.PeakName,
       p.Elevation
FROM Countries AS c 
JOIN MountainsCountries AS mc 
ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m
ON mc.MountainId = m.Id
JOIN Peaks AS p 
ON p.MountainId = m.Id
WHERE c.CountryCode = 'BG' AND p.Elevation >= 2835
ORDER BY p.Elevation DESC

SELECT CountryCode, COUNT(MountainId) AS [MountainRanges]
FROM MountainsCountries
WHERE CountryCode IN ('US', 'RU', 'BG')
GROUP BY CountryCode

SELECT ContinentCode, CurrencyCode, CurrencyCount AS [CurrencyUsage] 
FROM
    (SELECT ContinentCode, CurrencyCode, [CurrencyCount], 
    DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY CurrencyCount DESC) AS [CurrencyRank] 
    FROM 
        (
            SELECT ContinentCode,
            CurrencyCode,
            COUNT(*) AS [CurrencyCount]
            FROM Countries
            GROUP BY ContinentCode, CurrencyCode
        ) AS [CurrencyCountQuery]
    WHERE CurrencyCount > 1
    ) AS [CurrencyRankinkQuery]
WHERE CurrencyRank = 1
ORDER BY ContinentCode

SELECT TOP(5) c.CountryName, 
MAX(p.Elevation) AS [Highest Peak Elevation], 
MAX(r.[Length]) AS [Longest River Length]
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr 
ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r 
ON cr.RiverId = r.Id
LEFT JOIN MountainsCountries AS mc 
ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m 
ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p 
ON p.MountainId = m.Id
GROUP BY c.CountryName
ORDER BY [Highest Peak Elevation] DESC, [Longest River Length] DESC, c.CountryName ASC

SELECT TOP (5)  Country, 
        CASE 
            WHEN PeakName IS NULL THEN '(no highest peak)' 
            ELSE PeakName
        END AS [HighestPeakName], 
        CASE 
            WHEN Elevation IS NULL THEN 0
            ELSE Elevation
        END AS [HighestPeakElevation], 
        CASE 
            WHEN MountainRange IS NULL THEN '(no mountain)'
            ELSE MountainRange
        END AS [Mountain]
FROM
    (SELECT *, DENSE_RANK() OVER (PARTITION BY [Country] ORDER BY [Elevation] DESC) AS [PeakRank] 
    FROM
        (SELECT CountryName AS [Country],
            p.PeakName,
            p.Elevation,
            m.MountainRange
        FROM Countries AS c 
        LEFT JOIN MountainsCountries AS mc 
        ON c.CountryCode = mc.CountryCode
        LEFT JOIN Mountains AS m 
        ON mc.MountainId = m.Id
        LEFT JOIN Peaks AS p 
        ON m.Id = p.MountainId)
    AS [FullInfoQuery])
AS [PeakRankinkgsQuery]
WHERE [PeakRank] = 1
ORDER BY Country, [HighestPeakName]

SELECT e.EmployeeID, e.FirstName, e.LastName, d.Name AS [DepartmentName] FROM Employees AS e
JOIN Departments AS d 
ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY e.EmployeeID

SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.Name AS [DepartmentName] FROM Employees AS e
JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID

SELECT e.FirstName, e.LastName, e.HireDate, d.Name AS [DeptName] FROM Employees AS e 
JOIN Departments AS d 
ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1999.1.1' AND d.Name IN ('Sales', 'Finance')
ORDER BY e.HireDate

SELECT e.EmployeeID, e.FirstName, e.ManagerID, m.FirstName AS [ManagerName] FROM Employees AS e
JOIN Employees AS m 
ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN (3, 7)
ORDER BY e.EmployeeID

SELECT TOP(5) c.CountryName, r.RiverName FROM Countries AS c 
LEFT JOIN CountriesRivers AS cr 
ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r
ON cr.RiverId = r.Id
JOIN Continents AS cont 
ON c.ContinentCode = cont.ContinentCode
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

SELECT COUNT(c.CountryCode) AS [Count] FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON c.CountryCode = mc.CountryCode
WHERE mc.MountainId IS NULL

SELECT * FROM MountainsCountries

SELECT DepositGroup, MAX(MagicWandSize) AS [LongestMagicWand] 
FROM WizzardDeposits
GROUP BY DepositGroup

SELECT TOP(2) DepositGroup FROM
    (SELECT DepositGroup, AVG(MagicWandSize) AS [AVG Wand Size] 
    FROM WizzardDeposits
    GROUP BY DepositGroup)
AS [AvgMagigWandSizeQuery]
ORDER BY [AVG Wand Size]

SELECT DepositGroup, SUM(DepositAmount) AS [TotalSum] 
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander Family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY [TotalSum] DESC

SELECT AgeGroup, COUNT(*) AS [WizardsCount] FROM
    (SELECT 
    CASE 
        WHEN Age <= 10 THEN '[0-10]'
        WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
        WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
        WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
        WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
        WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
        ELSE '[61+]'
    END AS [AgeGroup], *
    FROM WizzardDeposits) 
AS [AgeGroupQuery]
GROUP BY [AgeGroup]

SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS [AverageInterest]
FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired ASC

SELECT SUM([Difference]) AS [SumDifference] FROM
    (SELECT FirstName AS [HostWizard],
        DepositAmount AS [Host Wizard Deposit],
        LEAD(FirstName) OVER(ORDER BY Id ASC) AS [GuestWizard],
        LEAD(DepositAmount) OVER(ORDER BY Id ASC) AS [Guest Wizard Deposit],
        DepositAmount -  LEAD(DepositAmount) OVER(ORDER BY Id ASC) AS [Difference]
    FROM WizzardDeposits) AS [LeadQuery]
WHERE [GuestWizard] IS NOT NULL

SELECT * INTO EmployeesWithHighSalaries FROM Employees
WHERE Salary > 30000

DELETE FROM EmployeesWithHighSalaries
WHERE ManagerID = 42

UPDATE EmployeesWithHighSalaries
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) AS [AverageSalary] FROM EmployeesWithHighSalaries
GROUP BY DepartmentID

SELECT DepartmentID, Salary AS [ThirdHighestSalary] FROM
    (
    SELECT DepartmentID,
    Salary, 
    DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS [SalaryRank]
    FROM Employees
    GROUP BY DepartmentId, Salary
    )
    AS [SalaryRankingsQuery]
WHERE SalaryRank = 3

SELECT TOP(10) e1.FirstName, e1.LastName, e1.DepartmentID
FROM Employees AS e1
WHERE e1.Salary > (
                  SELECT AVG(Salary) AS [AverageSalary]
                  FROM Employees AS e2
                  WHERE e2.DepartmentID = e1.DepartmentID
                  GROUP BY DepartmentID
                  )
ORDER BY DepartmentID

SELECT COUNT(*) FROM WizzardDeposits

SELECT TOP(1) MagicWandSize 
FROM WizzardDeposits
ORDER BY MagicWandSize DESC

SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS [MinDepositCharge] 
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

SELECT DISTINCT LEFT(FirstName, 1) AS [FirstLetter] FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY FirstName

SELECT DepartmentID, SUM(Salary) AS [TotalSalary] FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

SELECT DepartmentID, MIN(Salary) AS [MinimumSalary] FROM Employees
WHERE DepartmentID IN (2,5,7) AND HireDate > '2000/01/01'
GROUP BY DepartmentID

SELECT DepartmentID, MAX(Salary) AS [MaxSalary] FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) < 30000 OR MAX(Salary) > 70000

SELECT COUNT(Salary) AS [Count] FROM Employees
WHERE ManagerID IS NULL
GROUP BY ManagerID
