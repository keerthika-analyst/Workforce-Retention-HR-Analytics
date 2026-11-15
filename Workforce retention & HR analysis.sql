create database workforce_retention;
use workforce_retention;

drop database workforce_retention;


CREATE TABLE departments (
    DepartmentID VARCHAR(10) PRIMARY KEY,
    DepartmentName VARCHAR(100),
    Functions VARCHAR(100),
    HeadOfDepartment VARCHAR(100),
    CostCenter VARCHAR(30),
    TotalHeadcount INT
);

CREATE TABLE managers (
    ManagerID VARCHAR(10) PRIMARY KEY,
    ManagerName VARCHAR(100),
    DepartmentID VARCHAR(10),
    ManagerTenureYears DECIMAL(4,1),
    TeamSize INT,
    SpanOfControl VARCHAR(30),

    FOREIGN KEY (DepartmentID)
        REFERENCES departments(DepartmentID)
);

CREATE TABLE employees (
    EmployeeID VARCHAR(10) PRIMARY KEY,
    FullName VARCHAR(100),
    Age INT,
    Gender VARCHAR(20),
    MaritalStatus VARCHAR(30),
    EducationLevel VARCHAR(50),
    DepartmentID VARCHAR(10),
    JobRole VARCHAR(100),
    JobLevel VARCHAR(10),
    CurrentSalary DECIMAL(12,2),
    JoiningDate DATE,
    WorkLocation VARCHAR(50),
    CommuteDistanceKM DECIMAL(6,2),
    EmploymentType VARCHAR(30),
    ReportingManagerID VARCHAR(10),
    AttritionFlag VARCHAR(10),
    ExitDate DATE,
    ExitReason VARCHAR(100),

    FOREIGN KEY (DepartmentID)
        REFERENCES departments(DepartmentID),

    FOREIGN KEY (ReportingManagerID)
        REFERENCES managers(ManagerID)
);

CREATE TABLE attendance (
    RecordID VARCHAR(15) PRIMARY KEY,
    EmployeeID VARCHAR(10),
    MonthYear VARCHAR(20),
    WorkingDays INT,
    PresentDays INT,
    AbsentDays INT,
    AttendancePercent DECIMAL(5,2),
    OvertimeHours DECIMAL(6,2),
    WFHDays INT,
    WFHPercent DECIMAL(5,2),

    FOREIGN KEY (EmployeeID)
        REFERENCES employees(EmployeeID)
);

CREATE TABLE leave_records (
    LeaveID VARCHAR(15) PRIMARY KEY,
    EmployeeID VARCHAR(10),
    LeaveType VARCHAR(50),
    StartDate DATE,
    EndDate DATE,
    DaysTaken INT,
    ApprovalStatus VARCHAR(30),

    FOREIGN KEY (EmployeeID)
        REFERENCES employees(EmployeeID)
);

CREATE TABLE performance (
    RecordID VARCHAR(15) PRIMARY KEY,
    EmployeeID VARCHAR(10),
    ReviewPeriod VARCHAR(20),
    ReviewDate DATE,
    PerformanceRating INT,
    RatingCategory VARCHAR(50),
    GoalsMetPercent DECIMAL(5,2),
    ReviewerID VARCHAR(10),

    FOREIGN KEY (EmployeeID)
        REFERENCES employees(EmployeeID),

    FOREIGN KEY (ReviewerID)
        REFERENCES managers(ManagerID)
);

CREATE TABLE engagement (
    SurveyID VARCHAR(15) PRIMARY KEY,
    EmployeeID VARCHAR(10),
    SurveyDate DATE,
    EngagementScore INT,
    JobSatisfaction INT,
    WorkLifeBalance INT,
    ManagerSatisfaction INT,
    CareerGrowthScore INT,

    FOREIGN KEY (EmployeeID)
        REFERENCES employees(EmployeeID)
);

CREATE TABLE promotions (
    PromotionID VARCHAR(15) PRIMARY KEY,
    EmployeeID VARCHAR(10),
    PromotionDate DATE,
    FromRole VARCHAR(100),
    ToRole VARCHAR(100),
    FromLevel VARCHAR(10),
    ToLevel VARCHAR(10),
    SalaryHikePercent DECIMAL(5,2),

    FOREIGN KEY (EmployeeID)
	REFERENCES employees(EmployeeID)
);

drop table promotions;

CREATE TABLE training (
    TrainingID VARCHAR(15) PRIMARY KEY,
    EmployeeID VARCHAR(10),
    TrainingName VARCHAR(150),
    Category VARCHAR(50),
    CompletionDate DATE,
    DurationHours DECIMAL(6,2),
    CertificationEarned VARCHAR(10),

    FOREIGN KEY (EmployeeID)
        REFERENCES employees(EmployeeID)
);

CREATE TABLE risk_scores (
    EmployeeID VARCHAR(10) PRIMARY KEY,
    RiskScore INT,
    RiskCategory VARCHAR(30),
    ResignationProbability DECIMAL(6,4),
    RiskTrend VARCHAR(30),
    LastUpdated DATE,

    FOREIGN KEY (EmployeeID)
	REFERENCES employees(EmployeeID)
);

select * from departments;
select * from managers;
select * from employees;
select * from attendance;
select * from leave_records;
select * from performance;
select * from engagement;
select * from promotions;
select * from training;
select * from risk_scores;

SELECT COUNT(*) FROM managers;
SELECT COUNT(*) AS TotalPromotions
FROM promotions;


-- 1.Employee count:

select count(*) as employee_count from employees;

-- 2.Department headcount

select DepartmentID, count(*) as Employee_count from employees
group by DepartmentID;

select d.DepartmentName, count(e.EmployeeID) as Employee_count 
from departments d
left join employees e on d.DepartmentID = e.DepartmentID
group by d.DepartmentName
ORDER BY Employee_count DESC;

-- 3.Attrition analysis

SELECT AttritionFlag, count(*) from employees
group by AttritionFlag;

-- Attrition Rate analysis

select count(case when AttritionFlag = 'yes' then 1 end) as Attrition_employees,
count(*) as Total_employees, 
round(count(case when AttritionFlag = 'yes' then 1 end) * 100.0 / count(*), 2) as Attrition_rate
from employees;

-- Attrition by department

select d.DepartmentName,
count(e.EmployeeID) as Total_employee,
sum(case when e.AttritionFlag = 'yes' then 1 else 0 end) as Attrition
FROM employees e
JOIN departments d
on e.DepartmentID = d.DepartmentID
group by d.DepartmentName;

-- 4.Attendance analysis

select avg(AttendancePercent) as Average_attendance
from attendance;

-- Emplpoyee with low attendance

select EmployeeID, avg(AttendancePercent) as Average_attendance
from attendance
group by EmployeeID
having Average_attendance < 85
order by Average_attendance asc;

-- Employees absent days

select EmployeeID, sum(AbsentDays) as Absent_days
from attendance
group by EmployeeID
order by Absent_days asc;

-- Leave analysis

SELECT EmployeeID, SUM(DaysTaken) AS Total_Leave_Days
FROM leave_records
WHERE ApprovalStatus = 'Approved'
GROUP BY EmployeeID
ORDER BY Total_Leave_Days DESC;

-- Leave by type

select LeaveType, count(*) as Leave_request,
sum(DaysTaken) AS Total_Leave_Days
from leave_records
group by LeaveType;

-- performance analysis

SELECT EmployeeID,
AVG(PerformanceRating) AS AvgPerformance,
AVG(GoalsMetPercent) AS AvgGoalsMet
FROM performance
GROUP BY EmployeeID
ORDER BY AvgPerformance DESC;

-- High performance

SELECT EmployeeID,
AVG(PerformanceRating) AS AvgRating
FROM performance
GROUP BY EmployeeID
HAVING AVG(PerformanceRating) >= 4;

-- Low performance

SELECT EmployeeID,
AVG(PerformanceRating) AS AvgRating
FROM performance
GROUP BY EmployeeID
HAVING AVG(PerformanceRating) <= 3;

-- Employee engagement

SELECT
AVG(EngagementScore) AS AvgEngagement,
AVG(JobSatisfaction) AS AvgJobSatisfaction,
AVG(WorkLifeBalance) AS AvgWorkLifeBalance,
AVG(ManagerSatisfaction) AS AvgManagerSatisfaction,
AVG(CareerGrowthScore) AS AvgCareerGrowth
FROM engagement;

-- Employee with low engagement

SELECT
    EmployeeID,
    AVG(EngagementScore) AS AvgEngagement
FROM engagement
GROUP BY EmployeeID
HAVING AVG(EngagementScore) < 5
ORDER BY AvgEngagement asc;

-- Promotion analysis

SELECT
COUNT(*) AS TotalPromotions,
AVG(SalaryHikePercent) AS AvgSalaryHike,
MIN(SalaryHikePercent) AS MinHike,
MAX(SalaryHikePercent) AS MaxHike
FROM promotions;

-- Promotion count by employee:

SELECT EmployeeID,
COUNT(*) AS Promotion_Count
FROM promotions
GROUP BY EmployeeID
ORDER BY Promotion_Count DESC;

-- Training analysis

SELECT Category,
COUNT(*) AS TrainingCount,
SUM(DurationHours) AS TotalTrainingHours,
AVG(DurationHours) AS AvgTrainingHours
FROM training
GROUP BY Category
ORDER BY TotalTrainingHours DESC;

-- Training by employee

select EmployeeID,
count(*) as Training_count,
sum(DurationHours) as Training_hours
from training
group by EmployeeID
order by Training_hours asc;

-- Employee risk analysis

SELECT
    AVG(RiskScore) AS Average_Risk_Score
FROM risk_scores;

SELECT
    RiskCategory,
    COUNT(*) AS EmployeeCount,
    AVG(RiskScore) AS AvgRiskScore,
    AVG(ResignationProbability) AS AvgResignationProbability
FROM risk_scores
GROUP BY RiskCategory
ORDER BY AvgRiskScore DESC;

-- High risk employee

SELECT
    e.EmployeeID,
    e.FullName,
    e.DepartmentID,
    r.RiskScore,
    r.RiskCategory,
    r.ResignationProbability
FROM employees e
INNER JOIN risk_scores r
    ON e.EmployeeID = r.EmployeeID
WHERE r.RiskCategory = 'High'
ORDER BY r.RiskScore DESC;

-- Manager team analysis

SELECT
    m.ManagerID,
    m.ManagerName,
    d.DepartmentName,
    COUNT(e.EmployeeID) AS ActualTeamSize
FROM managers m
LEFT JOIN employees e
    ON m.ManagerID = e.ReportingManagerID
LEFT JOIN departments d
    ON m.DepartmentID = d.DepartmentID
GROUP BY
    m.ManagerID,
    m.ManagerName,
    d.DepartmentName
ORDER BY ActualTeamSize DESC;

-- Salary analysis

SELECT
    AVG(CurrentSalary) AS AverageSalary,
    MIN(CurrentSalary) AS MinimumSalary,
    MAX(CurrentSalary) AS MaximumSalary
FROM employees;

-- salary by department

SELECT d.DepartmentName,
COUNT(e.EmployeeID) AS Employees,
AVG(e.CurrentSalary) AS AvgSalary,
MIN(e.CurrentSalary) AS MinSalary,
MAX(e.CurrentSalary) AS MaxSalary
FROM employees e
INNER JOIN departments d
    ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName
ORDER BY AvgSalary DESC;

-- Case statement

select EmployeeID, FullName, CurrentSalary, 
case when CurrentSalary >= 1000000 then 'High salary'
when CurrentSalary >= 600000 then 'Medium salary'
else 'Low salary'
end as salary_category
from employees
order by salary_category asc;

-- Classify by attendance

SELECT
    EmployeeID,
    AVG(AttendancePercent) AS AvgAttendance,
    CASE
        WHEN AVG(AttendancePercent) >= 95 THEN 'Excellent'
        WHEN AVG(AttendancePercent) >= 85 THEN 'Good'
        ELSE 'Low'
    END AS AttendanceCategory
FROM attendance
GROUP BY EmployeeID;

-- SUBQUERY

select EmployeeID, FullName, CurrentSalary from employees
where CurrentSalary > (select avg(CurrentSalary) from employees)
order by Currentsalary desc;

-- CTE

WITH employee_performance AS (
    SELECT
        EmployeeID,
        AVG(PerformanceRating) AS AvgRating
    FROM performance
    GROUP BY EmployeeID
)
SELECT
    e.EmployeeID,
    e.FullName,
    ep.AvgRating
FROM employee_performance ep
INNER JOIN employees e
    ON ep.EmployeeID = e.EmployeeID
WHERE ep.AvgRating >= 4
ORDER BY ep.AvgRating DESC;

-- WINDOW FUNCTION

SELECT
    EmployeeID,
    FullName,
    DepartmentID,
    CurrentSalary,
    RANK() OVER (
        PARTITION BY DepartmentID
        ORDER BY CurrentSalary DESC
    ) AS SalaryRank
FROM employees;

-- Date function

SELECT
    EmployeeID,
    FullName,
    JoiningDate,
    TIMESTAMPDIFF(YEAR, JoiningDate, CURDATE()) AS Years_of_Service
FROM employees;

-- VIEWS

CREATE VIEW vw_employee_overview AS
SELECT e.EmployeeID, e.FullName, d.DepartmentName, m.ManagerName,
e.JobRole, e.JobLevel, e.CurrentSalary, e.AttritionFlag
FROM employees e
LEFT JOIN departments d
    ON e.DepartmentID = d.DepartmentID
LEFT JOIN managers m
    ON e.ReportingManagerID = m.ManagerID;
    
SELECT * FROM vw_employee_overview;

-- Department headcount

CREATE VIEW vw_department_headcount AS
SELECT d.DepartmentID, d.DepartmentName,
COUNT(e.EmployeeID) AS Headcount
FROM departments d
LEFT JOIN employees e
    ON d.DepartmentID = e.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName;
    
select * from vw_department_headcount;
