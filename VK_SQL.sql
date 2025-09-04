# select statement for columns

select * 
from parks_and_recreation.employee_demographics;

select first_name, last_name, birth_date,
age,
age + 10 
from parks_and_recreation.employee_demographics;

select distinct gender 
from parks_and_recreation.employee_demographics;

# where statement for rows
select * 
from parks_and_recreation.employee_salary
where first_name = 'Leslie' and salary > 50000;

select * 
from parks_and_recreation.employee_demographics
where birth_date > '1985-01-01';

select * 
from parks_and_recreation.employee_salary
where (first_name = 'Leslie' and salary > 50000) or salary < 50000;

# like statement for patterns
select * 
from parks_and_recreation.employee_demographics
where first_name like 'A%';

select * 
from parks_and_recreation.employee_demographics
where first_name like 'a__';

select * 
from parks_and_recreation.employee_demographics
where first_name like 'a__%';

# group by rolls up values into rows
select gender
from parks_and_recreation.employee_demographics
group by gender
;

select gender, avg(age)
from parks_and_recreation.employee_demographics
group by gender
;

select * 
from parks_and_recreation.employee_salary;


select occupation, avg(salary)
from parks_and_recreation.employee_salary
group by occupation
;

select gender, avg(age), max(age), min(age), count(age)
from parks_and_recreation.employee_demographics
group by gender
;

# order by
select *
from parks_and_recreation.employee_demographics
order by first_name;

select *
from parks_and_recreation.employee_demographics
order by gender, age, first_name, employee_id;

# having
select gender, avg(age) as avg_age, max(age), min(age), count(age)
from parks_and_recreation.employee_demographics
group by gender
having avg_age > 40
;

select occupation, avg(salary)
from parks_and_recreation.employee_salary
where occupation like '%manager%'
group by occupation
having avg(salary) > 75000
;

# limit
select *
from parks_and_recreation.employee_demographics
limit 5
;

select *
from parks_and_recreation.employee_demographics
order by age desc
limit 3, 1
;

# aliasing for name changing using as or not as with max_age 
select gender, avg(age) as avg_age, max(age) max_age, min(age), count(age)
from parks_and_recreation.employee_demographics
group by gender
having avg_age > 40
;

# joins
select *
from parks_and_recreation.employee_demographics
inner join employee_salary
	on employee_demographics.employee_id = employee_salary.employee_id
;

select *
from parks_and_recreation.employee_demographics as d
right join employee_salary as s
	on d.employee_id = s.employee_id
;

select s.employee_id, s.first_name, s.last_name, s.occupation, s.salary, d.age, d.gender, d.birth_date
from parks_and_recreation.employee_demographics as d
right join employee_salary as s
	on d.employee_id = s.employee_id
;

select *
from employee_salary e1
join employee_salary e2
	on e1.employee_id = e2.employee_id
;

select *
from employee_salary e1
join employee_salary e2
	on e1.employee_id + 1 = e2.employee_id
;

 select *
 from parks_and_recreation.parks_departments;
 
 select *
 from parks_and_recreation.employee_salary s
 left join parks_and_recreation.employee_demographics d
 on s.employee_id = d.employee_id
 inner join parks_and_recreation.parks_departments p
 on s.dept_id = p.department_id
 ;
 
 # unions combine rows together
 select age, gender
 from employee_demographics
 union
 select first_name, last_name
 from employee_salary
 ;
 
 select first_name, last_name, 'Old' as label
 from employee_demographics
 where age > 60
 union
 select first_name, last_name, 'Highly Paid' as label
 from employee_salary
 where salary > 70000
 ;
 
 # string functions
 select first_name, length(first_name)
 from employee_demographics
 order by 2
 ;
 
 select first_name, last_name, birth_date, substring(birth_date,6,2) birth_month
 from employee_demographics;
 
 select first_name, last_name,
 concat (first_name,' ',last_name) as full_name 
 from employee_demographics;
 
 select *
 from employee_salary
 order by salary desc
 limit 2,1;

# case statements
select first_name, last_name, age,
case
	when age <= 30 then 'young'
    when age between 31 and 50 then 'old'
    when age >= 51 then 'retiring'
end age_bracket
from employee_demographics
;

select s.first_name, s.last_name, s.occupation, s.salary, p.department_name,
case
	when s.salary < 50000 then s.salary * 1.05
    when s.salary > 50000 then s.salary * 1.07
    else s.salary
end as new_salary,
case
	when p.department_name = 'Finance' then s.salary * 0.10
end as bonus
from employee_salary s
inner join parks_departments p
	on s.dept_id = p.department_id
;

# subqueries
select *
from employee_salary
where employee_id in 
					(select employee_id
					from employee_demographics
                    where age < 40)
;

select first_name, last_name, salary,
(select avg(salary) 
from employee_salary) avg_sal
from employee_salary;

select *
from
(select gender, avg(age), max(age), min(age), count(age)
from employee_demographics
group by gender) as agg_table
;

select avg(max_age)
from
(select gender, avg(age) as avg_age, max(age) as max_age, min(age) as min_age, count(age)
from employee_demographics
group by gender) as agg_table
;

select gender, avg(age), max(age), min(age), count(age)
from employee_demographics
group by gender;

# windows function
select gender, avg(s.salary) as avg_salary
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
group by gender
;

-- will be same with the windows function below and we can add more columns without changing the group by results

select gender, avg(s.salary) over(partition by gender)
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

select d.first_name, d.last_name, gender, avg(s.salary) over(partition by gender) as avg_sal_gender
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

select d.first_name, d.last_name, gender, sum(s.salary) over(partition by gender) as sum_sal_gender
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

-- let's do a rolling total by gender
select d.first_name, d.last_name, gender, salary, sum(s.salary) over(partition by gender order by d.employee_id) as rolling_total
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

-- let's do a rolling total by employee_id
select d.first_name, d.last_name, gender, salary, sum(s.salary) over(order by d.employee_id) as rolling_total
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

-- let's do row number
select d.employee_id, d.first_name, d.last_name, gender, salary, 
row_number() over()
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

-- let's do row number per gender
select d.employee_id, d.first_name, d.last_name, gender, salary, 
row_number() over(partition by gender)
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

-- let's do row number per gender and order by salary (within the row number)
select d.employee_id, d.first_name, d.last_name, gender, salary, 
row_number() over(partition by gender order by salary desc) as row_num
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

-- let's do row number per gender, order by salary (within the row number), and add rank 1
select d.employee_id, d.first_name, d.last_name, gender, salary, 
row_number() over(partition by gender order by salary desc) as row_num,
rank() over(partition by gender order by salary desc) as rank_num
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

-- let's do row number per gender, order by salary (within the row number), and add rank 2
select d.employee_id, d.first_name, d.last_name, gender, salary, 
row_number() over(partition by gender order by salary desc) as row_num,
rank() over(order by salary desc) as rank_num
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

-- let's do row number per gender, order by salary (within the row number), and add dense rank 3
select d.employee_id, d.first_name, d.last_name, gender, salary, 
row_number() over(partition by gender order by salary desc) as row_num,
rank() over(partition by gender order by salary desc) as rank_num,
dense_rank() over(partition by gender order by salary desc) dense_rank_num
from employee_demographics d
join employee_salary s
	on d.employee_id = s.employee_id
;

# CTE (common table expression)
with cte_ex as (
select gender, avg(salary) avg_sal, max(salary) max_sal, min(salary) min_sal, count(salary) count_sal
from employee_salary s
inner join employee_demographics d
	on s.employee_id = d.employee_id
group by gender
)
select * from cte_ex
;

with cte_ex as (
select gender, avg(salary) avg_sal, max(salary) max_sal, min(salary) min_sal, count(salary) count_sal
from employee_salary s
inner join employee_demographics d
	on s.employee_id = d.employee_id
group by gender
)
select avg(avg_sal)
from cte_ex
;

-- so cte is like a subquery
select avg(avg_sal) 
from 
(select gender, avg(salary) avg_sal, max(salary) max_sal, min(salary) min_sal, count(salary) count_sal
from employee_salary s
inner join employee_demographics d
	on s.employee_id = d.employee_id
group by gender) as agg_sal
;

-- more than 1 ctes

with cte_ex1 as
(
select employee_id, gender, birth_date
from employee_demographics
where birth_date > '1985-01-01'
),
cte_ex2 as
(
select employee_id, salary
from employee_salary
where salary > 50000
)
select *
from cte_ex1
join cte_ex2
	on cte_ex1.employee_id = cte_ex2.employee_id
;

# temp tables
create temporary table temp_table (
	first_name varchar(50),
	last_name varchar (50),
	favorite_movie varchar(100)
);

select *
from temp_table;

insert into temp_table
values('Vike', 'Sailor', 'Terminator')
;

select *
from employee_salary;

create temporary table salary_over_50k
select *
from employee_salary
where salary >= 50000;

select *
from salary_over_50k;

# Stored procedures- save sql codes and call them for a procedure

create procedure large_salaries ()
select *
from employee_salary
where salary >= 50000;

call large_salaries;

-- better
use parks_and_recreation;
drop procedure if exists large_salaries2;
delimiter $$
use parks_and_recreation $$
create procedure large_salaries2 ()
begin
	select *
	from employee_salary
	where salary >= 50000;
    select *
    from employee_salary
    where salary >= 10000;
end $$
delimiter ;

call large_salaries2;

-- parameters = variables passed into stored procedure

delimiter $$
use parks_and_recreation $$
create procedure large_salaries3 (id_param int)
begin
	select *
	from employee_salary
	where employee_id = id_param;
    end $$
delimiter ;

call large_salaries3 (1)

# triggers

delimiter $$
create trigger employee_insert
	after insert on employee_salary
    for each row
begin
	insert into employee_demographics (employee_id, first_name, last_name)
    values (new.employee_id, new.first_name, new.last_name);
end $$
delimiter ;

insert into employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
values (13, 'Kevin', 'Judah', 'President', 500000, null);

# events are scheduled- reports automation

select * 
from employee_demographics;

delimiter $$
create event delete_retirees
on schedule every 30 second
do
begin
	delete
    from employee_demographics
    where age >= 60;
end $$
delimiter ;

show variables like 'event%';

-- create an event that gives me the new table very week
CREATE TABLE IF NOT EXISTS employee_snapshots (
    snapshot_date DATETIME,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    gender VARCHAR(10)
);

DELIMITER $$

CREATE EVENT weekly_employee_snapshot
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO employee_snapshots (snapshot_date, first_name, last_name, age, gender)
    SELECT 
        NOW() AS snapshot_date,
        TRIM(d.first_name) AS first_name,                 -- removes leading/trailing spaces
        TRIM(d.last_name) AS last_name,                   -- removes leading/trailing spaces
        NULLIF(d.age, '') AS age,                         -- handles empty string as NULL
        INITCAP(TRIM(d.gender)) AS gender                 -- normalize gender values like 'male' → 'Male'
    FROM employee_demographics d;
END $$

DELIMITER ;

-- create event log to monitor the schedule
CREATE TABLE IF NOT EXISTS event_log (
    event_name VARCHAR(100),
    run_time DATETIME,
    row_count INT
);

DELIMITER $$

CREATE EVENT log_weekly_snapshot
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN
    INSERT INTO employee_snapshots (snapshot_date, first_name, last_name, age, gender)
    SELECT NOW(), TRIM(first_name), TRIM(last_name), age, gender
    FROM employee_demographics;

    -- Log event activity
    INSERT INTO event_log (event_name, run_time, row_count)
    VALUES (
        'weekly_employee_snapshot',
        NOW(),
        ROW_COUNT()
    );
END $$

DELIMITER ;


select * from employee_snapshots;
SHOW VARIABLES LIKE 'event_scheduler';