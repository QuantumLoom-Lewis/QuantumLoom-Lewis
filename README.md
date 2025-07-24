# ⏰ Employee Time Tracking Database

A MySQL database schema and script to manage and track employee attendance, including clock-in/out times, daily hours worked, overtime, and fiscal week calculations.

---

## 📂 Database

```sql
CREATE DATABASE Employee_Time;
USE Employee_Time;
🗃️ Tables
👤 Employees
Stores employee information.


Copy
Edit
CREATE TABLE Employees (
  ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  surname VARCHAR(255) NOT NULL,
  department VARCHAR(255) NOT NULL,
  position VARCHAR(255) NOT NULL
) ENGINE=InnoDB;
🕒 Timelogs
Records employee clock-in/out times, daily hours, overtime, and fiscal week.


Copy
Edit
CREATE TABLE timelogs (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  emp_id INT NOT NULL,
  clock_in TIME,
  clock_out TIME,
  work_date DATE DEFAULT(CURRENT_DATE),
  daily_hrs DECIMAL(10,1),
  daily_over DECIMAL(5,1),
  fiscal_week INT,
  FOREIGN KEY (emp_id) REFERENCES Employees(ID)
) ENGINE=InnoDB;
📝 Note: A summary table was planned but removed due to redundancy.

🔄 Operations
✅ Initial Testing

Copy
Edit
SELECT * FROM timelogs;
SELECT * FROM employees;
🗓️ Fiscal Week Calculation
Assumes the fiscal year starts on April 1, 2025.


Copy
Edit
UPDATE timelogs
SET fiscal_week = TIMESTAMPDIFF(WEEK, '2025-04-01', work_date) + 1
WHERE id > 0;
🕰️ Daily Work Hours
Calculates total work hours per day.


Copy
Edit
UPDATE timelogs
SET daily_hrs = ROUND(TIME_TO_SEC(TIMEDIFF(clock_out, clock_in)) / 3600, 1)
WHERE id > 0;
⏱️ Overtime Calculation
Marks overtime when daily hours exceed 8.


Copy
Edit
UPDATE timelogs
SET daily_over = GREATEST(daily_hrs - 8, 0)
WHERE daily_hrs IS NOT NULL AND id > 0;
📊 Reporting
Join employee details with their work logs:


Copy
Edit
SELECT
  e.id, e.name, e.surname,
  t.clock_in, t.clock_out,
  t.daily_hrs, t.daily_over, t.fiscal_week
FROM timelogs t
INNER JOIN employees e ON t.emp_id = e.id;
Summarize daily hours by employee:


Copy
Edit
SELECT emp_id, ROUND(SUM(TIME_TO_SEC(TIMEDIFF(clock_out, clock_in)) / 3600), 1) AS daily_hours
FROM timelogs
GROUP BY emp_id;
⚙️ Requirements
MySQL 5.7+ or compatible

SQL access with permissions to create databases and tables

🚀 Getting Started
Copy the SQL script into your MySQL interface.

Run the script to set up the schema.

Populate the Employees and Timelogs tables.

Run the update statements to calculate hours and overtime.

💡 Future Improvements
Weekly/monthly summary reports

Integration with front-end dashboards

Role-based access for HR/admin use

Export to CSV or visualization tools

🧑‍💻 Author Notes
This script was developed with iterative testing, troubleshooting SQL safe updates, and optimizing for clarity in payroll/reporting use cases. Feel free to contribute or adapt to your needs.
