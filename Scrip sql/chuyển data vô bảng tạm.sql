-- Chuyển về master để tạo Database mới
USE master;
GO

-- 1. Tạo Database Staging riêng biệt
CREATE DATABASE Staging_HR_Analytics;
GO

USE Staging_HR_Analytics;
GO

-- 2. Tạo bảng Staging_Demographics hứng dữ liệu từ file Demographics.csv
CREATE TABLE Staging_Demographics (
    Employee_ID VARCHAR(50), 
    Department VARCHAR(100), 
    Gender VARCHAR(20), 
    Age INT, 
    Job_Title VARCHAR(100), 
    Hire_Date VARCHAR(50), 
    Years_At_Company INT, 
    Education_Level VARCHAR(50)
);

-- 3. Tạo bảng Staging_Performance hứng dữ liệu từ file Performance.csv
CREATE TABLE Staging_Performance (
    Employee_ID VARCHAR(50), 
    Performance_Score FLOAT, 
    Monthly_Salary DECIMAL(18,2), 
    Work_Hours_Per_Week INT, 
    Projects_Handled INT, 
    Overtime_Hours INT, 
    Sick_Days INT, 
    Remote_Work_Frequency VARCHAR(20), 
    Team_Size INT, 
    Training_Hours INT, 
    Promotions INT, 
    Employee_Satisfaction_Score FLOAT, 
    Resigned VARCHAR(20) -- Chữ True/False nên để Varchar
);

PRINT 'Tạo Database Staging và các bảng tạm thành công!';