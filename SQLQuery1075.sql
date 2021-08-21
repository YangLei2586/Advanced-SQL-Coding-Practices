#1075 project employee I average experience years for each project
o1
select p.project_id, round(avg(e.experience_years),2) as average_years
from Project p, Employee e
where p.employee_id = e.employee_id
group by p.project_id;

#1076 project have most employees  1) count correspodening employee_id 
s1 
select project_id
from project
group by project_id
having count(employee_id) =
 (select count(employee_id)
 from project 
 group by project_id
 order by count(employee_id) desc
 limit 1);
s2 
write a as(select project_id, count(employee_id) as ct
           from Project as p
		   group by project_id) 
select project_id
from a 
where a.ct = (select max(ct) from a);
s3 windows function 
with CTE as (
select project_id, rank() over(order by count(employee_id) desc) as ranking
from Project
group by project_id)

select project_id
from CTE
where ranking = 1
order by project_id;

#1077 most experienced employees in each project 
01 using windows function
select project_id, rank()over( partition by employee_id order by experience_years) as ranking
from Project p, Employee e
where p.employee_id = e.employee_id 
and ranking = 1
group by project_id;

02 using subquery
select project_id, employee_id
from Project p
join Employee e on p.employee_id = e.employee_id
where e.employee_id = ( select e.employee_id, max(e.expeirence_years)
                        from Employee
					  );
s1 1) lack of first layer 2) partition by project_id not employee_id
select t.project_id, t.employee_id
from ( select project_id, p.employee_id, rank()over(partition by project_id order by experience_years desc) as rank
       from Project p join Employee e
	   on p.employee_id = e.employee_id) t
where t.rank = 1;
s2 
select p.project_id, p.employee_id 
from Project p join Employee e
on p.employee_id = e.employee_id
where (p.project_id, e.experience_years) in ( select a.project_id, max(b.experience_years)
                                              from Project a join Employee b
											  on a.employee_id = b.employee_id
											  group by a.project_id);

s3 using CTE
with employee_experience as ( select p.project_id, e.employee_id,
                                     rank() over (partition by p.project_id order by experience_years desc) as rank
							  from Project p join Employee e
							  on p.employee_id = e.employee_id)
select project_id, employee_id
from employee_experience
where rank = 1;

#1082 sales analysis I  1) how to get total for one sale with multiple orders 
s1 having = ()
select seller_id 
from sales 
group by seller_id
having sum(price) = ( select sum(price)
                      from sales 
					  group by seller_id
					  order by 1 desc
					  limit 1);
s2 CTE 
with TEMP as ( select seller_id, sum(price) as price_sum
               from Sales
			   group by seller_id)
select seller_id
from TEMP
where price_sum = (select max(price_sum) from TEMP);

s3 windows function 
select seller_id 
from ( seller_id, rank()over(partition by seller_id order by sum(price) desc) as ranking
       from sales 
	   group by seller_id) a
where a.ranking = 1;

#1082 sales analysis II buy S8 not Iphone 1) why use not in instead of "!=Iphone"
s1 
select distinct buyer_id
from product p join sales s 
using product_id
where product_name = 's8'
and buyer_id not in ( select buyer_id 
                      from product p join sales s 
					  on p.product_id = s.product_id 
					  where product_name = 'Iphone');
s2 using case 
select a.buyer_id
from ( select buyer_id,
              max( case when product_name = 'S8' then 1 else 0 end) as s8,
			  max( case when product_name = 'iphone' then 1 else 0 end) as iphone 
	   from sales a
	   left join product p using (product_id)
	   group by buyer_id) 
where s8 = 1
and iphone = 0;

#1082 sales analysis III products sold in 2019 spring 1) why not between
s1 
select s.product_id, p.product_name
from sales s, product p 
where s.product_id = p.product_id
group by s.product_id, p.product_name
having min(s.sales_date) >= '2019-01-01'
and max(s.sales_date) <= '2019-03-31';
s2 
select distinct p.product_id,p.product_name
from product p join sales s
on p.product_id = s.product_id
where sale_date between '2019-01-01' and '2019-03-31'
and p.product_id not in ( select product_id from sales where sale_date < '2019-01-01'
                          union all 
						  select product_id from sales where sale_date > '2019-03-31') 
order by p.product_id;

#1097 Game play analysis V report install date, number of players and day 1 retention 
s1 
select a1.install_dt,count(*) installs, round(count(a2.event_date)/count(*), 2) Day1Retention
from ( select player_id, min(event_date) install_dt
       from Activity
	   group by player_id
	 ) a1 
left join Activity a2 
on a1.player_id = a2.player_id 
and datediff(a2.event_date, a1.install_dt) = 1
group by a1.install_dt;

select install_dt, count(player_id) as installs, round(count(next_day)/count(player_id),2) as Day1_Retention
from ( select a1.player_id, a1.install_dt, a2.event_date as next_day
       from ( select player_id, min(event_date) as install_dt
	          from Activity
			  group by player_id
			) as a1
	   left join Activity a2 
	   on a1.player_id = a2.player_id 
	   and a2.event_date = a1.install_dt + 1
	  ) as t 
group by install_dt;


#1757 for FaceBook Recyclable and low fat products 
select product_id 
from Products
where low_fats = 'Y'
and recylable = 'Y';

select round(avg(case when low_fats = 'Y' or recyclable = 'Y' then 1 else 0 end), 2) as percentage
from Products;

trips and users 1 find cancellation rate made by unbanned users between 10.1 to 10.3 round 2 decimal places
s1 
select t.request_at as Day, round(sum(t.status !='completed')/count(*),2) as 'Cancellation Rate'
from Trips t
join Users d on t.Driver_Id = d.User_id
join User c on t.Client_Id = c.User_Id
where d.banned = "No"
and c.banned = "No"
and t.Request_at between "2013-10-01" and "2013-10-03"
group by t.Request_at
order by t.Request_at;

s2 
with valid_user as ( select Users_Id from Users where Banned ="No"),
     valid_trips as (select * from Trips where Request_at between "2013-10-01" and "2013-10-03")
select t.Request_at As Day, Round(sum(t.status !="completed")/count(*),2) as 'Cancellation Rate'
from valid_trips t
join valid_user d on t.Dirver_Id = d.User_Id
join valid_user c on t.Client_Id = c.User_Id
group by t.Request_at;

Department Top 3 Salaries 
S1
with department_ranking as (select e.Name as Employee, d.Name as Department, e.Salary,
                                   dense_rank()over(partition by departmentId order by Salary Desc) as rnk 
from Employees e
join Department d
on e.DepartmentId = D.Id) 
select Department, Employee, Salary
from department_ranking
where rnk <= 3
order by Department ASC, Salary desc;

with department_ranking as (select e.Name as Employee, d.Name as Department, e.Salary,
                                             dense_rank()over(partition by departmentId order by Salary Desc) as rnk
from Employee e
join Department d
on e.DepartmentId = D.Id)
select Department, Employee, Salary
from department_ranking 
where rnk <= 3
order by Department ASC, Salary desc;

# query cumulative sum of an employees salary over a period of 3 months exclude the most recent monht

S1
select e.Id, e.Month, ifnull(e.Salary,0) + ifnull(e1.Salary,0) + ifnull(e2.Salary,0) as Salary
from Employee e
left join Employee e1 on e.Id = e1.Id and e.Month = e1.Month + 1
left join Employee e2 on e.Id = e2.Id and e.Month = e2.Month + 2
where (e.Id, e.Month) not in( select Id, Max(Month) as max_month
                              from Employee
							  group by Id)
order by e.Id asc, e.Month Desc;

s2 
select e.Id, e.Month, ifnull(e.Salary,0) + ifnull(e1.Salary,0) + ifnull(e2.Salary,0) as Salary
from (select Id, Max(Month) as max_Month
      from Employee
	  group by Id) as e_max
join Employee e ON e_max.Id = e.Id
left join Employee e1 on e.Id = e1.Id and e.Month = e1.Month + 1
left join Employee e2 on e.Id = e2.Id and e.Month = e2.Month + 2
where e_max.max_month != e.Month
order by e.Id asc, e.Month desc;

s3 using lag 
with cumulative as ( select Id, lag(Month,1) over(partition by Id order by Month ASC) as Month,
                            isnull(lag(Salary,1) over (partition by Id order by Month ASC), 0) 
						  + isnull(lag(Salary,2) over (partition by Id order by Month asc), 0)
						  + isnull(lag(Salary,3) over (partition by Id order by MOnth asc), 0) as Salary
					 from Employee) 
select * 
from cumulative
where Month is not null
order by Id asc, Month DESC;

s4 
with cumulative as ( select Id, lag(Month,1) over W as Month,
                            ifnull(lag(Salary,1) over W, 0)
						  + ifnull(lag(Salary,2) over W, 0) 
						  + ifnull(lag(Salary,3) over W, 0) as Salary
					 from Employee
					 Window W as (partition by Id order by Month ASC) 
select * 
from cumulative 
where Month is not null
order by Id asc, Month desc;

select e.Id, e.Month, ifnull(e.Salary,0) + ifnull(e1.Salary,0) + ifnull(e2.Salary,0) as Salary
from Employee e
left join Employee e1 on e.Id = e1.Id and e.Month = e1.Month + 1
left join Employee e2 on e.Id = e2.Id and e.Month = e2.Month + 2
where (e.Id, e.Month) not in ( select Id, max(Month) as max_month
                               from Employee
							   group by Id)
order by e.Id asc, e.Month desc;

select e.Id, e.Month, ifnull(e.Salary,0) + ifnull(e1.Salary,0) + ifnull(e2.Salary,0) as Salary
from Employee e 
left join Employee e1 using Id and e.Month = e1.Month + 1
left join Employee e2 using Id and e.Month = e2.Month + 2
where (e.Id,e.Month) not in ( select Id, max(Month) as max_month
                              from Employee
							  group by Id)
order by e.Id asc, e.Month desc;





							
                              


 
			  







                                     
