-- create a trigger to record information when an insert or delete event occurs against one specific table 
CREATE TRIGGER production.trg_product_audit
ON production.products
AFTER INSERT, DELETE
AS 
BEGIN
     SET NOCOUNT ON;
	 INSERT INTO production.product_audits(
	    product_id,
		product_name,
		brand_id,
		category_id,
		model_year,
		list_price,
		updated_at,
		operation
	 )
	 SELECT
	    i.product_id,
		product_name,
		brand_id,
		category_id,
		model_year,
		i.list_price,
		GETDATE(),
		'DEL'
	 FROM 
	    deleted d;
END

-- inserts a new row into the production.products table to test the trigger
INSERT INTO production.products(
     product_name,
	 brand_id,
	 category_id,
	 model_year,
	 list_price
)
VALUES(
     'test product',
	  1,
	  1,
	  2018,
	  599
);
#181 Employees earning more than their managers   1) no clues about how to relate and compare salary via manager id
select a.Name as 'Employee'
from Employee as a, Employee as b
where a.ManagerId = b.Id
  and a.salary > b.salary;
#182 Duplicate Emails 
select email
from Person
group by email
having count(email) > 1;
#183 Customers who never order 
select * from customer 
MINUS
select * from orders 

select customer, orderid
from customer c, orderid o
where c.id = o.id
group by customer 
having count(orderid)=0;   

select name as 'Customers'
from Customer c
left join Orders o
on c.id = o.id
and o.id is Null;
#184 Department Highest salary
#solution 1 using rank()
select Dpartment, Employee,Salary
from (
      select d.name Department,e.Name Employee, e.Salary,
	  rank() over(partition by d.id order by Salary desc) rk
	  from Employee e join Department d
	  on e.DepartmentId = d.id
	  ) tmp
where rk = 1;
#solution 2 using where in subquery
select 
     Department.name as 'Department',
	 Employee.name as 'Employee',
	 Salary,
from 
     Employee 
     join
	 Department 
	 on Employee.DepartmentId = Department.Id
where (Employee.DepartmentId, Salary) 
in ( select DepartmentId, max(Salary)
     from Employee
	 group by DepartmentId);
#185 Department Top 3 salary         not clear 1) only 2 employees no 3 salary 2) 
select e.Name as Employee, d.Name as Department, Salary,
       rank() over(partition by Department order by Salary desc) as rk
from Department d, Employee e
where e.DepartmentId = d.Id
    and rk <= 3;
# solution 1
 select Department, Employee, Salary
 from (
       select d.Name Department, e.Name Employee, e.Salary,
	   dense_rank() over(partition by d.id order by Salary desc) rk
	   from Employee e join Department d
	   on e.DepartmentId = d.id
	   ) tmp
where rk <= 3;
# solution 2
 with agg as (
              select DepartmentId, Name, Salary, 
			  dense_rank() over(partition by DepartmentId order by Salary desc) rk
			  from Employee)
select d.Name as Department, a.Name as Employee, a.Salary Salary
from agg a
join Department d on a.DepartmentId = d.Id
where a.rank < 4;

#196 Delete duplicate emails and keep that has min ID   1) how to express keep min id? 2) having count(*) > 1 for duplicating? 3) drop?
# solution 1 using self join
delete p1 from Person p1, p2
where  p1.Email = p2.Email 
  and  P1.Id > p2.Id
#197 Rising Temperature   1) how to express comparsion between today's and yesterday's temp self join? 
# solution 1
select weather.id as 'Id'
    from weather 
	join weather w on DATEDIFF(weather.recordDate, w.recordDate) = 1
	 and weather.Temperature > w.Temperature;
# solution 2
select Weather.Id 
from Weather
join Weather w
on w.RecordDate = SUBDATE(Weather.RecordDate, 1)
and Weather.Temperature > w.Temperature;
# solution 3
select Id from (
                select Id, RecordDate, Temperature,
				lag(RecordDate, 1,9999-99-99) over (order by RecordDate) yd,
				lag(Temperature, 1,999) over(order by RecordDate) yt
				from weather
				) tmp
where Temperature > yt
and datediff(RecordDate, yd) = 1;

#1211 Query quality and percentages   'don't have clue 1) how to express total query times n 2) how to express mathmatical formula
# solution 1
select query_name,
       round(avg(rating/position),2) quality,
	   round(sum(if(rating<3,1,0))/count(rating)*100,2) poor_query_percentage
 from  Queries
group by query_name;
select query_name,
       round(avg(rating/position),2) quality,
	   round(sum(if(rating<3,1,0))/count(rating)*100, 2) poor_query_percentage
from Queries
group by query_name;
#summary 1)no need to find out how many queries has been done avg will do this 2) sum if condition 

#597 friend requests overall acceptance rate      1) how to deal with 0 request? 2) how to nest select statement within round function?
select 
      ifnull(
	         ( select 
			         round(count(distinct accepter_id) / count(distinct requester_id) * 100, 2) acceptance_rate
			   from RequestAccepted r, FriendRequest f
			   where r.send_to_id = f.accepter_id
			   and  r.sender_id = f.requester_id
			  ),
	         0);
 
select 
       ifnull( 
	          round( (select count(distinct requester_id, accepter_id) from request_accepted) /
			         (select count(distinct sender_id,send_to_id) from friend_request), 
				   2),
			  0) as acceptenceRate;	 
			            
#614 follower and followee      1) how to relate the multiple followers to one followee? To be understood for future 
select f1.follower, count(distinct f2.follower) as num 
from follow as f1
join follow as f2
on f1.follower = f2.followee
group by f1.follower
order by f1.follower

#1412 find middle score students 
select student_id, student_name
from  (
        select distinct student_id
		from Exam
		where student_id not in 
		( 
		   select distinct student_id
		   from Exam e left join
		            (  # The highest test scores and the lowest scores
					   select exam_id, max(score) maxs, min(score) mins
					   from exam
					   group by exam_id
					) t
          on e.exam_id = t.exam_id
		  where score = maxs or score = mins
		)
	   ) t1
left join Student s
on s.student_id = t1.student_id
order by student_id
#1142 users activity for the past 30 days    1) how to express last 30 days curdate or datediff?
# find daily active user count for a period of 30 days ending 2019-07-27 inclusively
select activity_date day, count(distinct user_id) as active_users
from Activity
where activity_date between date_add('2019-07-27', interval -29 day) and '2019-07-27'
group by activity_date;
# find user avger session 
solution 1
select 
      ifnull(
	         round( 
			       count(distinct session_id) / count(distinct user_id), 2
				  ),
			0) as average_session
from Activity
where activity_date between date_add('2019-07-27', interval -29 day) and '2019-07-27'
group by activity_date;

solution 2 using CTE 
with CTE1 as (
select count(activity_type) as total
from Activity
where DATEDIFF(day, activity_date,'2019-07-27')<=30
and activity_type in ('scroll_down','send_message')),
    CTE2 as( 
select count(distinct user_id) as people
from Activity
where DATEDIFF(day,activity_date,'2019_07_27')<=30)
select round(cast(c1.total as float) / cast(c2.people as float),2)
from CTE1 C1, CTE2 C2 as average_sessions_per_user

solution 3
select round(cast(count(activity_type) as type float) / cast(count(distinct user_id) as float), 2) as average_sessions_per_user
from Activity
where DATEDIFF(day, activity_date,'2019-07-27')<=30
and activity_type in ('scroll_down','send_mesage')
             


					   






       

  
  