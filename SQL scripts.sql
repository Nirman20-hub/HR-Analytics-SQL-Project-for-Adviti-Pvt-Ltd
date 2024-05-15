select * from hr_analytics_dataset_adviti;
--- Checking for missing values or null values
select 
sum(case when Employee_ID is null then 1 else 0 end) as ID_missing,
sum(case when Employee_Name is null then 1 else 0 end) as Name_missing,
sum(case when Age is null then 1 else 0 end) as Age_missing,
sum(case when Gender is null then 1 else 0 end) as gender_missing,
sum(case when Salary is null then 1 else 0 end) as Salary_missing
from hr_analytics_dataset_adviti;

--- checking data types
SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Employee_ID';
  SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Employee_Name';
  SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Age';
  SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Years_of_Service';
  SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Position';
  SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Gender';
  SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Department';
SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Salary';
  SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'hr_analytics_dataset_adviti' AND COLUMN_NAME = 'Distance_from_Work';
  --- Changing data types for Employye ID 
ALTER TABLE hr_analytics_dataset_adviti
MODIFY COLUMN Employee_ID VARCHAR(10);
--- changing data type for distance from work
ALTER TABLE hr_analytics_dataset_adviti
MODIFY COLUMN  Distance_from_Work double;
--- checking for distincts values 
select distinct Gender from hr_analytics_dataset_adviti;
select distinct Position from hr_analytics_dataset_adviti;
select distinct Department from hr_analytics_dataset_adviti;
select distinct Education_Level from hr_analytics_dataset_adviti;
--- categorizing the gender as Male and female
UPDATE hr_analytics_dataset_adviti
SET Gender = 'Female'
WHERE Gender = 'F';
UPDATE hr_analytics_dataset_adviti
SET Gender = 'Male'
WHERE Gender = 'M';
---
UPDATE hr_analytics_dataset_adviti
SET Promotion = 1
WHERE Promotion = 'Yes';
UPDATE hr_analytics_dataset_adviti
SET Promotion = 0
WHERE Promotion = 'No';
--- changing AccountExec. and other different forms of AccountExecutive to Account Executive
update hr_analytics_dataset_adviti
set Position = 'AccountExecutive'
where Position = 'AccountExec.';
update hr_analytics_dataset_adviti
set Position = 'AccountExecutive'
where Position = 'Account Exec.';
update hr_analytics_dataset_adviti
set Position = 'Account Executive'
where Position = 'AccountExecutive';

--- coding education level in 4 levels 1 being the lowest level and 4 being the highest level of education
update hr_analytics_dataset_adviti
set Education_Level = 1
where Education_Level = 'Diploma';

update hr_analytics_dataset_adviti
set Education_Level = 2
where Education_Level = 'Bachelor''s';

update hr_analytics_dataset_adviti
set Education_Level = 3
where Education_Level = 'Master''s';

update hr_analytics_dataset_adviti
set Education_Level = 4
where Education_Level = 'PhD';
--- correcting position column with distinct values 
update attrition_table
set Position = 'Data Analyst'
where Position = 'DataAnalyst'
;
update attrition_table
set Position = 'CEO'
where Position = 'COO'
;
SET SQL_SAFE_UPDATES = 0;

--- finding employee attrition percentage
SELECT 
    COUNT(CASE WHEN Attrition = 'yes' THEN 1 END) AS yes_count,
    COUNT(CASE WHEN Attrition = 'no' THEN 1 END) AS no_count,
    (COUNT(CASE WHEN Attrition = 'yes' THEN 1 END) / COUNT(*)) * 100 AS attrition_rate
    from hr_analytics_dataset_adviti;
--- Attrtion rate is 50.13 percentage 

---  Now to see the relationship between factors and attrition we filter the data by yes attrition and create a temprorary table for this subset
create view attrition_table as
select * 
from hr_analytics_dataset_adviti
where Attrition = 'Yes' and Position <> 'Intern';     

--- Relation between Attrition and Years of service
select * from attrition_table;
--- avg year of service employee who leaves company 
select avg(Years_of_Service) from attrition_table;
--- categorise years of service as 0-10 ,11-20,21-30,31+yrs and finding percentages of attrition in each category of service year
with cte1 as (
with cte as (
 SELECT Years_of_Service,
		CASE 
                WHEN Years_of_Service <= 10 THEN '0-10'
                WHEN Years_of_Service <= 20  THEN '11-20'
                WHEN Years_of_Service <= 30  THEN '21-30'
                ELSE '31+yrs'
            END AS service_years
        FROM
            attrition_table)
            select count(service_years) as no_of_emp,service_years 
            from cte
            group by service_years
            )
            select *, round((no_of_emp/(select sum(no_of_emp) from cte1))*100,2) as percentage
            from cte1
            ;
--- salary wise attrition rates
--- Catrgorizing the salary into different salary bracket 
select * from attrition_table;
with cte1 as
(with cte as (
SELECT Salary,
		CASE 
                WHEN Salary <= 1000000 THEN 'Below 10 lakh'
                WHEN Salary <= 2000000 THEN ' between 10-20 lakh'
               WHEN Salary <= 3000000 THEN ' between 20-30 lakh'
               WHEN Salary <= 4000000 THEN ' between 30-40 lakh'
                WHEN Salary <= 5000000 THEN ' between 40-50 lakh'
                   WHEN Salary <= 6000000 THEN ' between 50-60 lakh'
                     WHEN Salary <= 7000000 THEN ' between 60-70 lakh'
                      WHEN Salary <= 8000000 THEN ' between 70-80 lakh'
                      WHEN Salary <= 9000000 THEN ' between 80-90 lakh'
                ELSE 'Above 90 lakh '
            END AS salary_range
        FROM
            attrition_table)
            select count(salary_range) as no_of_emp,salary_range
            from cte
            group by salary_range)
            select *, round((no_of_emp/(select sum(no_of_emp) from cte1))*100,2) as percentage
            from cte1
            ;
            
--- Department wise attrition rates
with cte as (
select Department,count(Department) as no_of_emp
 from attrition_table
 group by Department)
select *, round((no_of_emp/(select sum(no_of_emp) from cte))*100,2) as percentage
from cte;
--- Position wise attrition rates
with cte as (
select Position,count(Position) as no_of_emp
 from attrition_table
 group by position)
select *, round((no_of_emp/(select sum(no_of_emp) from cte))*100,2) as percentage
from cte
order by no_of_emp desc;

--- Gender Wise Attrition rates
with cte as (
select Gender,count(Gender) as no_of_emp
 from attrition_table
 group by Gender)
select *, round((no_of_emp/(select sum(no_of_emp) from cte))*100,2) as percentage
from cte
;

--- Performance rating wise  Attrition rates
select Performance_Rating from attrition_table;
with cte as (
select Performance_Rating,count(Performance_Rating) as no_of_emp
 from attrition_table
 group by Performance_Rating)
select *, round((no_of_emp/(select sum(no_of_emp) from cte))*100,2) as percentage
from cte
order by Performance_Rating asc
;
--- Promotion wise attrition rates
with cte as (
select Promotion,count(Promotion) as no_of_emp
 from attrition_table
 group by Promotion)
select *, round((no_of_emp/(select sum(no_of_emp) from cte))*100,2) as percentage
from cte
order by Promotion asc
;
---- relationship between Years of service and Promotion
SELECT  Promotion , count(Promotion = 'yes')FROM hr_analytics_dataset_adviti  group by Promotion ;
Alter view retention as 
with cte as (
SELECT *,
		CASE 
				WHEN Years_of_Service = 0 THEN 'Intern'
                WHEN Years_of_Service <= 10 THEN 'Fresher'
                WHEN Years_of_Service <= 20  THEN 'Intermediate'
                WHEN Years_of_Service <= 30  THEN 'Experienced'
                ELSE 'Leader'
            END AS exp_service
        FROM
            hr_analytics_dataset_adviti
             )
select exp_service,
count(Promotion='Yes') as Promoted 
from cte 
where Attrition = 'No'
	group by exp_service
;

Alter view attrition as 
with cte as (
SELECT *,
		CASE 
				WHEN Years_of_Service = 0 THEN 'Intern'
                WHEN Years_of_Service <= 10 THEN 'Fresher'
                WHEN Years_of_Service <= 20  THEN 'Intermediate'
                WHEN Years_of_Service <= 30  THEN 'Experienced'
                ELSE 'Leader'
            END AS exp_service
        FROM
            hr_analytics_dataset_adviti
             )
select exp_service,
count(Promotion='Yes') as Promoted_attrition 
from cte 
where Attrition = 'Yes'
	group by exp_service
;

select * from attrition a
join  retention r
on a.exp_service = r.exp_service;

--- overall comparison

select 'Total Employees' AS category, COUNT(Employee_ID) AS total_employees, round(avg(Age),2) as avg_age,round(avg(Salary),2) as avg_salary, round(avg(Years_of_Service),2) as avg_experience,round(avg(Performance_Rating),2) as avg_performance, round(avg(Work_Hours),2) as avg_worktime, round(avg(Distance_from_Work),2) as avg_commute ,round(avg(Training_Hours),2) as avg_training_hours, round(avg(Satisfaction_Score),2) as avg_satisfacton_score
from hr_analytics_dataset_adviti
Union all
select 'Attritioned:Yes' AS category, COUNT(Employee_ID) AS attritioned,round(avg(Age),2) as avg_age,round(avg(Salary),2) as avg_salary, round(avg(Years_of_Service),2) as avg_experience,round(avg(Performance_Rating),2) as avg_performance, round(avg(Work_Hours),2) as avg_worktime, round(avg(Distance_from_Work),2) as avg_commute,round(avg(Training_Hours),2) as avg_training_hours, round(avg(Satisfaction_Score),2) as avg_satisfacton_score
from hr_analytics_dataset_adviti where Attrition = 'Yes'
Union all
select 'Attritioned : No' AS category, COUNT(Employee_ID) AS retained,round(avg(Age),2) as avg_age ,round(avg(Salary),2) as avg_salary, round(avg(Years_of_Service),2) as avg_experience,round(avg(Performance_Rating),2) as avg_performance, round(avg(Work_Hours),2) as avg_worktime, round(avg(Distance_from_Work),2) as avg_commute,round(avg(Training_Hours),2) as avg_training_hours, round(avg(Satisfaction_Score),2) as avg_satisfacton_score
from hr_analytics_dataset_adviti where Attrition = 'No';

---- problem 2 
----
with cte as (
select Performance_Rating,
	case 
		when Training_Hours < 10 then '0-10'
        when Training_Hours < 20 then '10-20'
		when Training_Hours < 30 then '20-30'
        when Training_Hours < 40 then '30-40'
        else '40-50'
        end as 'Training_hours_category'
         from hr_analytics_dataset_adviti)
         select Training_hours_category ,count(*) as no_of_employees, avg(Performance_Rating) as avg_performace_score
         from cte 
         group by Training_hours_category
         order by Training_hours_category;
---


---- Training hours and promotion 
with cte as (
select Promotion,
	case 
		when Training_Hours < 10 then '0-10'
        when Training_Hours < 20 then '10-20'
		when Training_Hours < 30 then '20-30'
        when Training_Hours < 40 then '30-40'
        else '40-50'
        end as 'Training_hours_category'
         from hr_analytics_dataset_adviti)
         select Training_hours_category ,count(*) as no_of_employees, sum(Promotion) as no_of_promotions
         from cte 
         group by Training_hours_category
         order by Training_hours_category;

--- Additional Analysis

         