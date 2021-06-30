# 06/26/2021 
#175 Combine Two Tables 
select FirstName, LastName, City, State
from Person p left join Address a
on p.PersonId = a.PersonId
#176 Second Highest salary 
select 
      IFNULL( 
	         (select distinct salary
			  from employee
			  order by salary desc
			  limit 1 offset 1),
			Null) 
	 as SecondHighestSalary

select ifnull((select distinct salary from employee order by salary desc limit 1 offset 1),null) as SecondHighestSalary;

select (
        select distinct salary
		from Employee
		order by salary desc
		limit 1 offset 1) as SecondHighestSalary;

#177 Get the Nth highest salary 
CREATE FUNCTION GetNthHighestSalary(N int) RETURNS INT
BEGIN
DECLARE M INT;
SET M=N-1
Return ( select distinct salary 
         from Employees 
		 order by Salary desc 
		 limit M offset 1);
END
#178 Rank Scores SQL-Server
select Score,
Dense_Rank() over (order by Score desc) as 'Rank'
from Scores;
select Score,
Dense_Rank() over (order by Score desc) as 'Rank'
from Scores;
#180 Consecutive Numbers 
select distinct Num as ConsecutiveNums 
from (
      select Id,Num, LEAD(Num,1) over() as Post_1, LEAD(Num,2) over() as Post_2
	  from Logs) as t 
where Num=Post_1
and Post_1 = Post_2;
select distinct Num as consecutivenums
from (
      select Id, Num, LEAD(Num,1) over() as post_1, LEAD(Num,2) over() as post_2
	  from Logs) as t
where Num = post_1
and post_1 = post_2;
#181 Employees earn more than their managers
select a.Name as Employee
from Employee as a 
join Employee as b 
on a.ManagerID = b.Id
where a.salary > b.salary;
#182 Duplicate emails 
select email
from Person
group by email
having count(email)>1;
#183 Customers who never order
select a.Name as Customers
from Customers as a 
left join Orders as b
on a.Id = b.CustomerId
where b.Id is null;

select Name as Customers 
from Customers
where Id not in( select CustomerId from orders);
#184 Department Highest salary
select b.Name as Department, a.Name as Employee, a.Salary
from 
    (select *, RANK() OVER(partition by DepartmentId ORDER BY Salary desc) as rk from Employee) as a
join Department as b
on a.DepartmentId = b.Id
where a.rk = 1;

select b.Name as Department, a.Name as Employee, a.Salary
from Employee as a 
join Department as b
on a.DepartmentId = b.Id
where(a.DepartmentId, a.salary) 
in (select DepartmentId, Max(Salary)
    from Employee
	group by DepartmentId);

select b.Name as Department, a.Name as Employee, a.Salary
from ( select *, Rank() over(partition by DepartmentId order by Salary desc) as rk from Employee) as a 
Join Department as b
on a.DepartmentId = b.Id
where a.rk=1;

select b.Name as Department, a.Name as Employee, a.Salary
from Employee as a 
join Department as b
on a.DepartmentId = b.Id
where (a.DepartmentId, a.Salary) In
(select DepartmentId, MAX(Salary)
 from Employee
 group by Department);

#185 Department top 3 salaries 
select b.Name as Department, a.Name as Employee, a.Salary
from ( select *, dense_rank() over(partition by DepartmentId order by Salary DESC) AS rk from Employee) as a 
join Department as b
on a.DepartmentId = b.Id
where a.rk<=3;

#196 Delete duplicate emails
delect a 
from Person as a, Person as b
where a.Email = b.Email
and a.Id > b.Id;

#197 Rising temperature 
select w1.id
from Weather w1, Weather W2
where Datediff(w1.recordDate, w2.recordDate)=1 
and w1.Temperature > w2.Temperature;

#262 Trips and Users 
select t.Request_at as Day,
Round(sum(if(t.Status = 'completed',0,1)) / count(t.Status), 2) as 'Cancellation Rate'
from Trips as t
join Users as u1
on (t.client_Id=u1.Users_Id and u1.Banned='no') 
where t.Request_at between '2013-10-01' and '2013-10-03'
group by t.Request_at;

#511 game play analysis 1 first_login_date 
select player_id, min(event_date) as first_login 
from activity
group by player_id;

#512 first_login_device 
select player_id, device_id
from activity 
where (player_id, event_date) in
(select player_id, min(event_date)
 from activity 
 group by player_id);
 
 select player_id, device_id
 from (
       select player_id, device_id, rank() over(partition by player_id order by event_date) as rk
	   from activity t
	   where t.rk =1 );
#513 games played so far
select player_id, event_date, sum(games_played) over(partition by player_id order by event_date) as games_played_so_far
from activity

#530 relogin_rate
select round(count(t2.player_id)/count(t1.player_id),2) as fraction 
from ( 
       select player_id, min(event_date) as min_date
	   from activity
	   group by player_id
	 ) t1
left join activity t2
on (t1.player_id = t2.player_id)
and (datediff(t2.event_date, t1.min_date) = 1);

#569 Employee salary median 
select t.Id,t.Company, t.Salary
from (
      select *,
	  row_number() over(partition by Company order by Salary) as rk
	  count(Id) over(partition by Company) as cnt
	  from Employee
	 ) t
where t.rk>=t.cnt/2 
and t.rk <= t.cnt/2+1;

select Id, Company, Salary
from (
      select *, row_number() over(partition by company order by Salary ASC, Id ASC) as RN_ASC,
	  row_number() over(partition by company order by Salary desc, Id desc) as RN_DESC
	  from Employee) as temp
where RN_ASC between RN_ASC -1 and RN_DESC + 1
order by Company, Salary;

select min(A.Id) as Id, A.Company, A.Salary
from Employee A, Employee B
where A.company = B.company
group by A.company, A.salary
having sum(case when B.salary >= A.salary then 1 else 0 end) >= count(*)/2
and sum(case when B.salary <= A.salary then 1 else 0 end) >= count(*)/2

#570 Managers having at least 5 reports >>in how to get 5 and connect two tables 

 select b.Name
 from (
       select ManagerId
	   from Employee
	   group by ManagerId
	   having count(Id) > 5
	  ) a
join Employee b
on b.Id = a.ManagerId;

select name 
from employee
where id 
in ( select managerId 
     from  employee
	 where managerId is not Null
	 group by managerId
	 having count(managerId) >=5); 
#571 find median given frequency of numbers 
select avg(t.Number) as median
from (
      select *, 
	  sum(frequency) over(order by number) as ascend_sum,
	  sum(frequency) over(order by number) as descend_sum,
	  sum(frequency) over() as total_frequency
	  from numbers
	 ) t 
where t.ascend_sum >= t.total_frequency/2 
and   t.descend_sum >= t.total_frequency/2;

#The key is to understand that if a number is a median it's frequency must be greater or equal 
#than the diff of total frequency of numbers greater or less than itself

select avg(number) as median
from (
       select 1.number 
	   from numbers 1 join numbers r
	   group by 1
	   having abs(sum(sign(1.number - r.numbers)* r.frequency)) <= max(1.frequency)
	 ) t;

select avg(t.number) as median
from (
      select *,
	  sum(frequency) over(order by number) as ascend_sum,
	  sum(frequency) over(order by number) as descend_sum,
	  sum(frequency) over() as total_frequency
	  from numbers
	 ) t
where t.ascend_sum >= t.total_frequency/2
and   t.descend_sum > = t.total_frequency/2;




 
 
