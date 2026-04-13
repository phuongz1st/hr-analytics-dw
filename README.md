# README – Hướng Dẫn Cài Đặt và Chạy Hệ Thống

## Đề Tài: Xây Dựng Data Warehouse Quản Lý Nhân Sự và Đánh Giá KPI Nhân Viên
- 2286400025 – Nguyễn Đông Phương

---

## Cấu Trúc Thư Mục Nộp Bài

```
submission/
├── DW_HR_2/                    ← Dự án ETL (SSIS)
│   ├── Package.dtsx            ← SSIS Package chính (4 tasks ETL)
│   ├── DW_HR_2.dtproj          ← Project file Visual Studio
│   ├── DW_HR_2.database        ← Database config
│   ├── Project.params          ← Parameters
│   ├── __SQLEXPRESS_DW_HR_Analytics_2.conmgr  ← Connection Manager
│   └── DW_HR_2.ispac           ← Package deployment file
│
├── DW_CUBE_HR/                 ← Dự án OLAP Cube (SSAS)
│   ├── Cube_Payroll_Retention.cube     ← Cube phân tích lương
│   ├── Cube_Performance_Tracking.cube ← Cube phân tích hiệu suất
│   ├── Time_Hirachi.cube               ← Time dimension cube
│   ├── Dim_Date.dim                    ← Dimension thời gian
│   ├── Dim_Employee.dim                ← Dimension nhân viên (SCD2)
│   ├── Dim_Department.dim              ← Dimension phòng ban
│   ├── Dim_Job_Role.dim                ← Dimension chức vụ
│   ├── Dim_Work_Arrangement.dim        ← Dimension hình thức làm việc
│   ├── DW_HR_Analytics_2.ds            ← Data Source
│   ├── DW_HR_Analytics_2.dsv           ← Data Source View
│   ├── DW_CUBE_HR.dwproj               ← Project file SSAS
│   └── DW_CUBE_HR.database             ← Database config SSAS
│
├── data/
│   ├── Employee_Demographics.csv       ← Dữ liệu nhân khẩu học (100.000 bản ghi)
│   └── Employee_Performance.csv        ← Dữ liệu hiệu suất (100.000 bản ghi)
│
├
│               
│
├── mdx/
│   └── MDXQuery1.mdx                   ← 5 câu truy vấn MDX
│
├── demo/
│   └── demo_5_phep_toan.xlsx           ← Kết quả 5 phép toán OLAP
│
├── dashboard/
│   └── HR_Analytics_Dashboard.pbix     ← Power BI Dashboard
│
└── README.md                           ← File này
│
└── report_vietnamese                   ← file report  
```

---

## Yêu Cầu Hệ Thống

| Phần mềm | Phiên bản | Ghi chú |
|----------|-----------|---------|
| Windows | 10/11 (64-bit) | Bắt buộc |
| SQL Server | 2019 Express trở lên | Miễn phí tại microsoft.com |
| SQL Server Management Studio (SSMS) | 19.x | Miễn phí tại microsoft.com |
| Visual Studio | 2019/2022 | Community Edition (miễn phí) |
| SQL Server Integration Services (SSIS) | Extension cho VS | Cài qua VS Extension Manager |
| SQL Server Analysis Services (SSAS) | Extension cho VS | Cài qua VS Extension Manager |
| Power BI Desktop | Mới nhất | Miễn phí tại powerbi.microsoft.com |

---

## Hướng Dẫn Cài Đặt Từng Bước

### BƯỚC 1 – Cài Đặt SQL Server Express

1. Tải SQL Server 2019 Express tại:  
   https://www.microsoft.com/en-us/sql-server/sql-server-downloads
2. Chạy installer, chọn **Basic Installation**
3. Ghi nhớ tên instance (mặc định: `.\SQLEXPRESS`)
4. Cài thêm **SQL Server Management Studio (SSMS)**

---

### BƯỚC 2 – Tạo Database

Mở SSMS, kết nối tới `.\SQLEXPRESS`, chạy lần lượt các lệnh SQL sau:

#### 2a. Tạo Staging Database

```sql
CREATE DATABASE Staging_HR_Analytics;
GO

USE Staging_HR_Analytics;
GO

-- Bảng staging Demographics
CREATE TABLE STG_Demographics (
    Employee_ID         VARCHAR(50),
    Department          VARCHAR(100),
    Gender              VARCHAR(20),
    Age                 INT,
    Job_Title           VARCHAR(100),
    Hire_Date           VARCHAR(50),   -- VARCHAR vì cần chuẩn hóa sau
    Years_At_Company    INT,
    Education_Level     VARCHAR(50)
);

-- Bảng staging Performance
CREATE TABLE STG_Performance (
    Employee_ID                 VARCHAR(50),
    Performance_Score           FLOAT,
    Monthly_Salary              DECIMAL(18,2),
    Work_Hours_Per_Week         INT,
    Projects_Handled            INT,
    Overtime_Hours              INT,
    Sick_Days                   INT,
    Remote_Work_Frequency       INT,
    Team_Size                   INT,
    Training_Hours              INT,
    Promotions                  INT,
    Employee_Satisfaction_Score FLOAT,
    Resigned                    BIT
);
```

#### 2b. Tạo Data Warehouse Database

```sql
CREATE DATABASE DW_HR_Analytics_2;
GO

USE DW_HR_Analytics_2;
GO

-- Dimension Tables
CREATE TABLE Dim_Date (
    Date_SK      INT PRIMARY KEY,
    Date_NK      DATE,
    Week         INT,
    Month        INT,
    Month_Name   VARCHAR(20),
    Quarter      INT,
    Quarter_Name VARCHAR(10),
    Year         INT,
    IsWeekend    BIT,
    IsHoliday    BIT
);

CREATE TABLE Dim_Employee (
    Employee_SK      INT IDENTITY(1,1) PRIMARY KEY,
    Employee_ID      VARCHAR(50),
    Gender           VARCHAR(20),
    Age              INT,
    Education_Level  VARCHAR(50),
    Hire_Date        DATE,
    Years_At_Company INT,
    Effective_Date   DATE,
    End_Date         DATE,
    Is_Current       BIT DEFAULT 1
);

CREATE TABLE Dim_Department (
    Department_SK   INT IDENTITY(1,1) PRIMARY KEY,
    Department_Name VARCHAR(100)
);

CREATE TABLE Dim_JobRole (
    JobRole_SK         INT IDENTITY(1,1) PRIMARY KEY,
    Job_Title          VARCHAR(100),
    Previous_Job_Title VARCHAR(100)
);

CREATE TABLE Dim_WorkArrangement (
    Arrangement_SK        INT IDENTITY(1,1) PRIMARY KEY,
    Remote_Work_Frequency VARCHAR(20),
    Team_Size             INT
);

-- Fact Tables
CREATE TABLE Fact_Performance (
    Performance_SK      INT IDENTITY(1,1) PRIMARY KEY,
    Employee_SK         INT FOREIGN KEY REFERENCES Dim_Employee(Employee_SK),
    Department_SK       INT FOREIGN KEY REFERENCES Dim_Department(Department_SK),
    JobRole_SK          INT FOREIGN KEY REFERENCES Dim_JobRole(JobRole_SK),
    Arrangement_SK      INT FOREIGN KEY REFERENCES Dim_WorkArrangement(Arrangement_SK),
    Date_SK             INT FOREIGN KEY REFERENCES Dim_Date(Date_SK),
    Performance_Score   FLOAT,
    Projects_Handled    INT,
    Work_Hours_Per_Week INT,
    Overtime_Hours      INT,
    Training_Hours      INT
);

CREATE TABLE Fact_HRPayroll (
    HRPayroll_SK                INT IDENTITY(1,1) PRIMARY KEY,
    Employee_SK                 INT FOREIGN KEY REFERENCES Dim_Employee(Employee_SK),
    Department_SK               INT FOREIGN KEY REFERENCES Dim_Department(Department_SK),
    Date_SK                     INT FOREIGN KEY REFERENCES Dim_Date(Date_SK),
    Monthly_Salary              DECIMAL(18,2),
    Sick_Days                   INT,
    Promotions                  INT,
    Employee_Satisfaction_Score FLOAT,
    Is_Resigned                 BIT
);

-- ETL Log Table
CREATE TABLE ETL_Log (
    Log_ID         INT IDENTITY(1,1) PRIMARY KEY,
    Run_Date       DATETIME DEFAULT GETDATE(),
    Task_Name      VARCHAR(100),
    Table_Name     VARCHAR(100),
    Rows_Inserted  INT DEFAULT 0,
    Rows_Updated   INT DEFAULT 0,
    Rows_Skipped   INT DEFAULT 0,
    Status         VARCHAR(20),
    Error_Message  VARCHAR(500),
    Duration_Sec   INT
);
```

---

### BƯỚC 3 – Cài Đặt Visual Studio và Extensions

1. Tải Visual Studio 2022 Community: https://visualstudio.microsoft.com/
2. Trong VS Installer, chọn workload: **Data storage and processing**
3. Sau khi cài, mở VS → Extensions → Manage Extensions → tìm và cài:
   - **Microsoft Analysis Services Projects** (SSAS)
   - **Microsoft Integration Services Projects** (SSIS)
4. Khởi động lại Visual Studio

---

### BƯỚC 4 – Chạy ETL (SSIS)

1. Mở Visual Studio → **File → Open → Project/Solution**
2. Chọn file `DW_HR_2/DW_HR_2.dtproj`
3. Trong Solution Explorer → double-click **Package.dtsx**
4. Kiểm tra Connection Manager:
   - Chuột phải vào `__SQLEXPRESS.DW_HR_Analytics_2` → **Edit**
   - Đảm bảo Server Name là `.\SQLEXPRESS` và Database là `DW_HR_Analytics_2`
5. Cập nhật đường dẫn file CSV:
   - Double-click Connection Manager **Conn_Demo_CSV** → sửa đường dẫn tới `Employee_Demographics.csv`
   - Double-click Connection Manager **E_Peformance** → sửa đường dẫn tới `Employee_Performance.csv`
6. Chạy package: **Debug → Start Debugging (F5)**
7. Theo dõi Control Flow – 4 tasks phải chuyển màu xanh lá theo thứ tự:
   - `0_Clear_Staging_Data` ✅
   - `1_Load_Staging` ✅
   - `2_Load_Dimensions` ✅
   - `3_Load_Facts` ✅

**Kiểm tra kết quả trong SSMS:**

```sql
USE DW_HR_Analytics_2;

-- Kiểm tra số bản ghi
SELECT 'Fact_Performance' AS Bang, COUNT(*) AS Tong FROM Fact_Performance
UNION ALL
SELECT 'Fact_HRPayroll', COUNT(*) FROM Fact_HRPayroll
UNION ALL
SELECT 'Dim_Employee', COUNT(*) FROM Dim_Employee
UNION ALL
SELECT 'Dim_Department', COUNT(*) FROM Dim_Department;
-- Kỳ vọng: Fact = 100.000 mỗi bảng

-- Kiểm tra khóa ngoại mồ côi (phải = 0)
SELECT COUNT(*) AS Orphaned
FROM Fact_Performance f
LEFT JOIN Dim_Employee e ON f.Employee_SK = e.Employee_SK
WHERE e.Employee_SK IS NULL;
```

---

### BƯỚC 5 – Deploy và Process OLAP Cube (SSAS)

1. Mở Visual Studio → **File → Open → Project/Solution**
2. Chọn file `DW_CUBE_HR/DW_CUBE_HR.dwproj`
3. Kiểm tra Data Source: Solution Explorer → Data Sources → double-click **DW HR Analytics 2.ds** → Edit → Test Connection → phải báo **"Test connection succeeded"**
4. Deploy Cube: **Build → Deploy DW_CUBE_HR**
   - Kết quả mong đợi: `Deploy complete -- 0 errors, 0 warnings`
5. Process Cube:
   - Solution Explorer → Cubes → chuột phải **Cube_Payroll_Retention.cube** → **Process** → **Run**
   - Chờ: `Process succeeded` ✅
   - Lặp lại với **Cube_Performance_Tracking.cube**

**Lưu ý lỗi thường gặp khi Deploy:**
- *"duplicate attribute key – Quarter"*: Đã xử lý bằng composite KeyColumns {Year, Quarter}
- *"NameColumn should be defined"*: Đặt NameColumn = Quarter cho attribute Quarter
- *"Deployment Failed"*: Kiểm tra SQL Server Analysis Services đang chạy (Services → SQL Server Analysis Services → Start)

---

### BƯỚC 6 – Chạy Truy Vấn MDX

1. Mở **SQL Server Management Studio (SSMS)**
2. **Connect → Analysis Services** → Server: `.\SQLEXPRESS` → OK
3. **New Query → MDX**
4. Mở file `mdx/MDXQuery1.mdx`
5. Copy từng câu query → chạy bằng **F5**
6. Chụp màn hình kết quả từng câu

---

### BƯỚC 7 – Mở Dashboard Power BI

1. Cài Power BI Desktop: https://powerbi.microsoft.com/desktop
2. Mở file `dashboard/HR_Analytics_Dashboard.pbix`
3. Nếu cần refresh dữ liệu: **Home → Refresh**
4. Nếu báo lỗi kết nối: **Home → Transform Data → Data Source Settings** → sửa server thành `.\SQLEXPRESS`

---

## Thứ Tự Chạy Hệ Thống (Tóm Tắt)

```
[1] Tạo DB          →  Chạy SQL scripts (Bước 2)
[2] Cài tools       →  VS + SSIS + SSAS extensions (Bước 3)
[3] Chạy ETL        →  Mở DW_HR_2.dtproj → F5 (Bước 4)
[4] Deploy Cube     →  Mở DW_CUBE_HR.dwproj → Deploy → Process (Bước 5)
[5] Query MDX       →  SSMS → MDXQuery1.mdx (Bước 6)
[6] Xem Dashboard   →  Power BI → HR_Analytics_Dashboard.pbix (Bước 7)
```

---

## Kiểm Tra Nhanh Hệ Thống Đang Chạy

```sql
-- Trong SSMS, chạy để xác nhận DW đã có dữ liệu:
USE DW_HR_Analytics_2;
SELECT
    (SELECT COUNT(*) FROM Fact_Performance)   AS Fact_Performance,
    (SELECT COUNT(*) FROM Fact_HRPayroll)     AS Fact_HRPayroll,
    (SELECT COUNT(*) FROM Dim_Employee)       AS Dim_Employee,
    (SELECT COUNT(*) FROM Dim_Department)     AS Dim_Department,
    (SELECT COUNT(*) FROM Dim_JobRole)        AS Dim_JobRole,
    (SELECT COUNT(*) FROM Dim_Date)           AS Dim_Date;
-- Kết quả mong đợi: Fact = 100.000 | Dim_Employee = 100.000 | Dept = 9 | JobRole = 7 | Date > 0
```

---

## Liên Hệ

Nếu gặp lỗi khi cài đặt, liên hệ tôi qua email:
- nguyendongphuong741@gmail.com (Nguyễn Đông Phương)

---


