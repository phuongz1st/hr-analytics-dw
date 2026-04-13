CREATE DATABASE DW_HR_Analytics;
GO
USE DW_HR_Analytics;
GO

-- 1. DDL TẠO DIMENSION
CREATE TABLE Dim_Date (
Date_SK INT PRIMARY KEY,
Date_NK DATE,
Year INT, 
Quarter INT, 
Month INT,
IsWeekend BIT, 
IsHoliday BIT
);


CREATE TABLE Dim_Department (
Department_SK INT IDENTITY(1,1) PRIMARY KEY, 
Department_Name VARCHAR(100));


CREATE TABLE Dim_JobRole (
JobRole_SK INT IDENTITY(1,1) PRIMARY KEY, 
Job_Title VARCHAR(100),
Previous_Job_Title VARCHAR(100));


CREATE TABLE Dim_WorkArrangement (
Arrangement_SK INT IDENTITY(1,1) PRIMARY KEY, 
Remote_Work_Frequency VARCHAR(20), 
Team_Size INT);


CREATE TABLE Dim_Employee (
Employee_SK INT IDENTITY(1,1) PRIMARY KEY,
Employee_ID VARCHAR(50),
Gender VARCHAR(20),
Age INT,
Education_Level VARCHAR(50),
Effective_Date DATE, 
End_Date DATE, 
Is_Current BIT DEFAULT 1);

-- 2. DDL TẠO FACT
CREATE TABLE Fact_Performance (
    Performance_SK INT IDENTITY(1,1) PRIMARY KEY,
    Employee_SK INT FOREIGN KEY REFERENCES Dim_Employee(Employee_SK),
    Department_SK INT FOREIGN KEY REFERENCES Dim_Department(Department_SK),
    JobRole_SK INT FOREIGN KEY REFERENCES Dim_JobRole(JobRole_SK),
    Arrangement_SK INT FOREIGN KEY REFERENCES Dim_WorkArrangement(Arrangement_SK),
    Date_SK INT FOREIGN KEY REFERENCES Dim_Date(Date_SK),
    Performance_Score FLOAT, 
    Projects_Handled INT, 
    Work_Hours_Per_Week INT, 
    Overtime_Hours INT, 
    Training_Hours INT
);

CREATE TABLE Fact_HRPayroll (
    HRPayroll_SK INT IDENTITY(1,1) PRIMARY KEY,
    Employee_SK INT FOREIGN KEY REFERENCES Dim_Employee(Employee_SK),
    Department_SK INT FOREIGN KEY REFERENCES Dim_Department(Department_SK),
    Date_SK INT FOREIGN KEY REFERENCES Dim_Date(Date_SK),
    Monthly_Salary DECIMAL(18,2), 
    Sick_Days INT, Promotions INT,
    Employee_Satisfaction_Score FLOAT,
    Is_Resigned BIT
);

