create database project;
use project;

select * from hr;

-- rename id column
alter table hr
change column ï»¿id emp_id varchar(20) null;

-- check data types
describe hr;
select birthdate from hr;

-- put off safe update remember to set it back to 1
set sql_safe_updates = 0;

-- changing date format for the birthdate column
update hr
set birthdate = case
when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
else null
end;

-- changing data type of the brthdate
alter table hr
modify column birthdate date;

-- changing data format for hire_date column
select hire_date from hr;


update hr
set hire_date = case
when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
else null
end;

-- changing data types for hire_date
alter table hr
modify column hire_date date;

-- changing data formats for termdate
select termdate from hr;
update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

-- setting empty spaces to null
update hr
set termdate = null
where termdate = '';

update hr
set termdate = "neche"
where termdate is null;

update hr
set termdate = null
where termdate = "neche";

-- changing data type for termdate
alter table hr
modify column termdate date;

select * from hr;

-- adding age column
alter table hr
add column age int;

-- calculating the age
update hr
set age = timestampdiff(year,birthdate, curdate());

-- checking outliers
select
	min(age) as youngest,
	max(age) as oldest
from hr;

select count(*) 
from hr
where age < 18;

-- analysis
-- 1 what is the gender distribution of employees in the company?
select gender, count(*) as count
from hr
where age >= 18 and termdate is null
group by gender;

-- the race breakdown of employee in the company
select race, count(*) as count
from hr
where age >= 18 and termdate is null
group by race 
order by count desc;

-- what is the age distribution of employee in the company
select 
min(age) as youngest,
max(age) as oldest
from hr
where age >= 18 and termdate is null;

-- creating the age group
select case
	when age >= 18 and age <= 24 then "18-24"
    when age >= 25 and age <= 34 then "25-34"
    when age >= 35 and age <= 44 then "35-44"
    when age >= 45 and age <= 54 then "45-54"
    when age >= 55 and age <= 64 then "55-64"
    else "65+"
    end as age_group, count(*) as count
    from hr
    where age >= 18 and termdate is null
    group by age_group
    order by age_group asc;
    
--   4  how is the gender distributed among the age_group
select case
	when age >= 18 and age <= 24 then "18-24"
    when age >= 25 and age <= 34 then "25-34"
    when age >= 35 and age <= 44 then "35-44"
    when age >= 45 and age <= 54 then "45-54"
    when age >= 55 and age <= 64 then "55-64"
    else "64+"
    end  as age_group, gender, count(*) as count
    from hr
    where age >= 18 and termdate is null
    group by age_group, gender
    order by age_group, gender;
    
  --   how many employee workes at headquarters vs remote location
  select * from hr;
  
  select location, count(*) as count
  from hr
  where age >= 18 and termdate is null
  group by location;
  
--   6 what is the average length of employement for employees who are terminated
select round(avg(datediff(termdate, hire_date))/365,0) as avg_lan_emp
from hr
where age >= 18 and termdate is not null and termdate <= curdate();

-- 7 how does gender distribution varrirs accross department
select department, gender, count(*)
from hr
where age >= 18 and termdate is null
group by department, gender
order by department;

-- distribution of job titles across the company
select jobtitle, count(*) as count
from hr
where age >= 18 and termdate is null
group by jobtitle
order by jobtitle desc;

-- 8 distribution of employee accross location by state
select location_state, count(*) as count
from hr
where age >= 18 and termdate is null
group by location_state
order by count desc;

-- 9 department with high turnover rate
select department, 
total_count, 
terminated_count,
terminated_count / total_count as termination_rate
from(
select department,
count(*) as total_count,
sum(case when termdate is not null and termdate <= curdate() then 1 else 0 end) as terminated_count
from hr
where age >= 18
group by department) as subquery
order by termination_rate desc;

-- 10 how has the comapny employee count changed over time based on hire and termination date
select year,
hires,
terminations,
hires-terminations as net_change,
round((hires-terminations)/hires * 100,2) as net_change_percent
from(
select year(hire_date) as year,
count(*) as hires,
sum(case when termdate is not null and termdate <= curdate() then 1 else 0 end) as terminations
from hr
where age >=18
group by year(hire_date)
)as subquery
order by year asc;

-- 11 what is tenure disttribution for each department
select department,
round(avg(datediff(termdate,hire_date) /365),0) as avg_tenure
from hr
where age >= 18 and termdate <= curdate() and termdate is not null
group by department
order by avg_tenure;