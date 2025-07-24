create database Employee_Time;
use employee_time;

-- creating a table to store the data of the employee themself

drop table if exists Employees;
create table Employees(
	ID int not null auto_increment primary key,
    name varchar(255) not null,
    surname varchar(255) not null,
    department varchar(255) not null,
    position varchar(255) not null)
ENGINE=InnoDB;

-- creating a table to store the clock-in and clock-out times of each employee

drop table if exists timelogs;
create table timelogs(
	id int not null auto_increment primary key,
    emp_id int not null,
    clock_in time,
    clock_out time,
    work_date date default(current_date),
    foreign key (emp_id) references Employees(ID))
engine=iNNOdb;

-- testing to make sure the imported data has successfully been integrated

select * from timelogs;
select * from employees;

-- adding a new column to calculate hours and hours over expected

alter table timelogs
add column daily_hrs decimal(10,1),
add column daily_over decimal(5,1),
add column fiscal_week INT;

-- calculating week number since start of financial year

select timestampdiff(week, '2025-04-01', date) + 1 as fiscal_week
from timelogs;

-- testing to find the daily hours of the employees

select 
  emp_id,
  round(sum(time_to_sec(timediff(clock_out, clock_in)) / 3600), 1) as daily_hours
from timelogs
group by emp_id;

-- adding the newly tested daily hours test into the table
-- this caused me issues due to SQL's safe mode settings. After some research, adding the where clause was apparently the solution

update timelogs
set daily_hrs = round(time_to_sec(timediff(clock_out, clock_in)) / 3600, 1)
where id > 0;

-- updating the table with information for the fiscal week

update timelogs
set fiscal_week = timestampdiff(week, '2025-04-01', work_date) + 1
where id > 0;

-- implementing the overtime calculation into the table itself

update timelogs
set daily_over = greatest(daily_hrs - 8,0)
where daily_hrs is not null and id > 0;

-- joining the tables so only the relevant information for the intended purpose is shown.

select e.id,
	e.name,
    e.surname,
    t.clock_in,
    t.clock_out,
    t.daily_hrs,
    t.daily_over,
    t.fiscal_week
from timelogs t
inner join employees e on t.emp_id = e.id;

select * from timelogs;


-- select * from timelogs where clock_in is null or clock_out is null;
-- This was to check that there was no null data in what was being calculated

-- calculating the overtime hours from the daily work hours
-- had an issue with the group-by for a while, but it was fixed by adding work_date

-- select emp_id, work_date, daily_hrs, greatest(daily_hrs - 8, 0) as overtime
-- from(
-- 	select emp_id,
--  work_date,
--  round(sum(time_to_sec(timediff(clock_out, clock_in)) / 3600), 2) as daily_hrs
-- from timelogs
-- group by emp_id, work_date)
-- as daily_summary;
