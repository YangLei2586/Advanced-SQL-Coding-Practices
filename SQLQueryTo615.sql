#574 Winning candidate 
select b.Name
from (
      select candidateId
	  form vote
	  group by candidateId
	  order by count(id) desc
	  limit 1
	 ) a 
join candidate b
on b.id = a.candidatedId;

select c.name 
from candidate c
where id in ( select candidateId 
              from vote 
			  group by candiateId
			  order by count(id) desc
			  limit 1);
#577 employee bonus
select a.name, b.bonus
from employee a
left join Bonus b
on a.empId = b.empId
where b.bonus < 1000
or b.bonus is null;

#578 highest answered rate question
select question_id, survey_log
from survey_log
group by questio_id
order by sum(if(action='answer',1,0)/sum(if(action='show',1,0)) desc
limit 1;
s1
select question_id, survey_log
from (
      select question_id,
	         sum(if(action='answer', 1,0)) as AnswerCnt,
			 sum(if(action='show',1,0)) as ShowCnt
	  from  survey_log
	  group by question_id
	  ) as tb1
order by(AnserCnt/ShowCnt) desc
limit 1;
s2
select question_id, survey_log
from survey_log
group by question_id
order by sum(if(action='answer',1,0))/sum(if(action='show',1,0)) desc
limit 1;
s3 
with tmp as ( select question-id,
                     sum(case when answer_id is not null then 1 else 0 end) /count(*) as rate
			  from  survey_log
			  group by question_id) 
select question_id as survey_log
from tmp
where rate in ( select max(rate) from tmp);
                     

#579 find cumulative salary of an employee >> 1 exclude max month 2 latest 3 month 3 3 month cumulative salary show month by month
s1
select A.Id, Max(B.Month) as Month, Sum(B.Salary) as Salary
from Employee A, Employee B
where A.Id = B.Id
and B.Month between (A.Month - 3) and (A.Month - 1) 
group by A.Id, A.Month
order by Id, Month desc;
s2 
select t.Id, t.Month, t.Salary + If(t.pre1, t.pre1,0) + If(t.pre2,t.pre2,0) as Salary
from (
      select *, lag(Salary,1) over(partition by Id order by Month) as pre1,
	            lag(Salary,2) over(partition by Id order by Month) as pre2,
				Row_Number() over(partition by Id order by Month DESC) as rk
				from Employee
	  ) as t
where t.rk>1;

#580 Count student number in departments 
o1
select d.dept_name as dept_name, count(s.dept_id) as student_number, 
       rank() over(partition by student_number order by dept_name desc) as rk
from department
left join student s
on s.dept_id = d.dept_id
group by dept_name
order by student_number desc;
o2
select d.dept_name, count(s.student_id) as student_number
from department d 
left join student s
on d.dept_id = s.dept_id
group by student_number desc, dept_name asc;
o3
select dept_name, ifnull(count(s.student_id),0) as student_number 
from Department d
left join student s
on s.dept_id = d.dept_id
group by dept_name
order by student_number desc

s1 
select b.dept_name, if(a.student_number, a.student_number,0) as student_number
from ( select dept_id, count(student_id) as student_number 
       from student
	   group by dept_id
	 ) a
right join department b
on a.dept_id = b.dept_id
order by a.student_number desc, b.dept_name

#584 find customer referee
select name
from customer 
where referee_id != 2;

#585 Insurance investment >> 1) row differences compared with a column 2) lat + lon unique 
s1 
select sum(t.TIV_2016) as TIV_2016
from ( select distinct a.pid, a.TIV_2016
       from insurance a join insurance b
	   on a.PID != b.PID
	   and (a.LAT, a.LON) not in ( select LAT,LON
	                               from insurance
								   where PID!=a.PID
								  )
where a.TIV_2015 = b.TIV_2015
group by a.PID) as t 



#586 Customer placing the largest number of orders 
select customer_number
from orders
group by customer_number 
order by count(order_number) desc
limit 1;

#595 big countries 
select name, population, area
from world
where area > 30000000
or population > 250000000;

#596 classes more than 5 students  1) subquery not direct query
o1 
select class 
from courese 
having count(student) > 5;
s1
select class
from (
      select class, count(disctinct student) as cnt
	  from courses
	  group by class
	  ) t 
where t.cnt >= 5; 
o2 
select class
from courese
group by class
having count(distinct student) >= 5;

#597 friend request overall acceptance rate 1) why need subquery not direct query 2) why select pair instead one
s1
select ifnull(round(sum(a.cnt_accept)/sum(b.cnt_send), 2),0) as accept_rate
from (
      select count(*) as cnt_accept
	  from ( 
	         select distinct requester_id, accpeter_id
			 from RequestAccepted
		   ) t1
	 ) a,
	 (select count(*) as cnt_send
	  from (
	        select distinct sender_id, send_to_id
			from FriendRequest
			) t2
	 ) b ;
s2 
select ifnull(round((count(distinct requester_id, accepter_id) / count(distinct sender_id, send_to_id)), 2), 0.00) as accept_rate
from friend_request, request_accepted;
s3
select round(
             ifnull( 
			         ( select count(*) from (select distinct requester_id, accepter_id from request_accepted) as A)
					 /
					 ( select count(*) from (select distinct sender_id, send_to_id from friend_request) as B),
			     0)
			 , 2) as accept_rate;

s4 using join 
select if(f.ct = 0, 0.00, cast(r.ct/f.ct as decimal(4,2))) as accept_rate
from ( 
       select count(distinct sender_id, send_to_id) as ct
	   from friend_request) as f
join ( select count(distinct requester_id, accepter_id) as ct
       from request_accepter) as r
s5 
select ifnull((round(accepts/requests,2)),0.0) as accept_rate
from ( select count(distinct sender_id, sender_to_id) as requests
       from friend_request) as t1,
     ( select count(distinct requester_id, accpter_id) as accepts 
	   from request_accepted) as t2;
#597 following question1: accept rate for every month
select if(d.req=0, 0.00, round(c.acp/d.req,2)) as accept_rate, c.month 
from ( select count(distinct requester_id, accepter_id) as acp, Month(accept_date) as month from requste_accepted) c,
     ( select count(distinct sender_id, send_to_id) as req, Month(request_date) as month from friend_request) d
where c.month = d.month
group by c.month

select if(d.req=0,0, round(c.acp / d.req, 2)) as accept_rate, c.month
from (select count(distinct requester_id, accepter_id) as acp, Month(accept_date) as month from request_accepted) c,
     (select count(distinct sender_id, send_to_id) as req, Month(request_date) as month from friend_request) d,
where c.month = d.month
group by c.month

#597 following question2: accept rate for every day
select s.date1, ifnull(round(sum(case when t.ind = 'a' then t.cnt else 0 end)/ sum(case when t.ind = 'r' then t.cnt else 0 end),2),0)
from ( select distinct x.request_date as date1 from friend_request x
       union
	   select distinct y.accept_date as date1 from request_accepted y ) s 
left join 
     ( select v.request_date as date1, count(*) as cnt, 'a' as ind from friend_request v group by v.requst_date
	   union all
	   select w.accept_date as date1, count(*) as cnt, 'a' as ind from request_accepted w group by w.accept_date) t
on s.date1 >= t.date1
group by s.date1
order by s.date1

#601 stadium human traffic 
s1 
select s1.* from stadium as s1, stadium as s2, stadium as s3
where ( 
       (s1.id + 1 = s2.id and s1.id + 2 = s3.id) 
	   or 
	   (s1.id - 1 = s2.id and s1.id + 1 = s3.id) 
	   or 
	   (s1.id - 2 = s2.id and s1.id - 1 = s3.id) 
	  ) 
and s1.people >= 100
and s2.people >= 100
and s3.people >= 100
group by s1.id;

s2 joining 3 tables 
select distinct t1.*
from stadium t1, stadium t2, stadium t3
where t1.people >= 100 and t2.people >=100 and t3.people >=100
and (  
      (t1.id - t2.id = 1 and t1.id - t3.id = 2 and t2.id - t3.id = 1) -- t1,t2,t3
   or (t2.id - t1.id = 1 and t2.id - t3.id = 2 and t1.id - t3.id = 1) -- t2,t1,t3
   or (t3.id - t2.id = 1 and t2.id - t1.id = 1 and t3.id - t1.id = 2) -- t3,t2,t1
    ) 
order by t1.id;

s3 using window functions lag and lead 
select id, visit_date, people 
from (
       select id,
	   lead(people, 1) over (order by id) 1d,
	   lead(people, 2) over (order by id) 1d2,
	   visit_date,
	   lag(people, 1) over (order by id) lg,
	   lag(people, 2) over (order by id) lg2,
	   people
	   from stadium 
	 ) a 
where (a.1d >= 100 and a.lg >= 100 and a.people >= 100)
   or (a.ld >= 100 and a.lg2 >= 100 and a.people >= 100)
   or (a.lg >= 100 and a.lg2 >= 100 and a.people >= 100);
 
s4 
select ID, visit_date, people 
from ( select ID, visit_date, people,
              lead(people, 1) over (order by id) nxt,
			  lead(people, 2) over (order by id) nxt2,
			  lag(people,1) over (order by id) pre,
			  lag(people,2) over (order by id) pre2
	   from stadium
	 ) cte 
where (cte.people >= 100 and cte.nex >= 100 and cte.nxt2 >= 100)
   or (cte.people >= 100 and cte.nxt >= 100 and cte.pre >= 100)
   or (cte.people >= 100 and cte.pre >= 100 and cte.pre2 >= 100)

s5 using case and condition check
select id, visit_date, people
from ( select id, visit_date, people,
              case when min(people) over(order by id rows between current row and 2 following) >= 100 then 'YES'
			       when min(people) over(order by id rows between 1 preceding and 2 following) >= 100 then 'YES'
				   when min(people) over(order by id rows between 2 preceding and current row) >= 100 then 'YES'
				   else 'NO'
			  end as condition_check
	   from tmp
	 ) t
where condition_check =' YES'
order by 2;

#602 who has the most friends 1) query to express the most meaning 2) how to define and caculate friends from self joining tables 
s1 
select rid as 'id', count(aid) as 'num'
from ( select R1.requester_id as rid, R1.accepter_id as aid
       from requst_accepted as R1
	   union all
	   select R2.accepter_id as rid, R2.requester_id as aid
	   from request_accepted as R2
	 ) as A
group by rid
order by num desc
limit 0, 1;
s2
select id1 as id, count(id2) as num
from ( 
      select requester_id as id1, accepter_id as id2
	  from request_accepted 
	  union 
	  select accepter_id as id1, requester_id as id2
	  from requester_accepeted
	  ) tmp1
group by id1
order by num desc 
limit 1;

s3 
with a as ( select requester_id as id from request_accepted
            union all 
			select accepter_id as id from request_accepted) 
select id, count(id) as num
from a 
group by id
order by num desc
limit 1;
s4 using sum 
select id, sum(num_friends) as num
from (select count(*) as num_friends, accepter_id as id from request_accepted group by accepter_id
      union all 
	  select count(*) as num_friends, requester_id as id from request_accepted group by requester_id) as d
group by id 
order by sum(num_friends) desc
limit 1;
 
#603 Consecutive available seats  1) how to express consecutive 2) >= 2  3)  ensure at least 2 consecutive seats 
s1 using self join
select distinct a.seat_id 
from cinema a 
join cinema b
on abs(a.seat_id - b.seat_id) = 1
and a.free = true 
and b.free = true 
order by a.seat_id;

select distinct a.seat_id
from cinema a, cinema b
where a.free = 1 
and   b.free = 1
and (a.seat_id + 1 = b.seat_id or a.seat_id = b.seat + 1)   not solve 3, 4, 5 and larger consective seats problems 
order by a.seat_id asc;

s2 using window functions 
select seat_id 
from  ( select seat_id, free, sum(cast(free as int)) over(order by seat_id rows between 1 preceding and 1 following) as sum
        from cinema
	  ) x
where x.sum >= 2
and x.free = '1'
order by seat_id asc;

s3 using lag and lead function
select seat_id
from ( select seat_id, free,
              lag(free, 1) over(order by seat_id) as free_lag,
			  lead(free,1) over(order by seat_id) as free_lead
	   from cinema) as t
where (free = 1 and free_lag = 1)
or (free = 1 and free_lead = 1);

s4 using subquery in 
select seat_id 
from cinema
where free = 1 
and (   (seat_id - 1) in (select seat_id from cinema where free = 1) 
     or (seat_id + 1) in (select seat_id from cinema where free = 1)
	);
s5 lag lead subquery
select seat_id
from ( select seat_id,
              lag(seat_id, 1, -99) over(order by seat_id) ls,
			  lead(seat_id, 1,-99) over(order by seat_id) rs,
	   from cinema
	   where free = 1
	 ) t1
where seat_id - ls = 1 
or    rs - seat_id = 1;

#607 salesperson  1) did not sale anything to Red 
o1 not sure where is wrong 
select s.name as sales 
from salesperson s, company c, orders o
where s.sales_id = o.sales_id
and c.com_id = o.com_id
and c.name != 'RED';  
s1 
select salesperson.name
from orders o join company c on (o.com_id = c.com_id and c.name = 'RED')
right join salesperson on salesperson.sales_id = o.sales_id 
where o.sales_id is null;

s2  in + not in subquery
select name from salesperson 
where sales_id not in ( select sales_id from orders where com_id in 
                          (select com_id from company where name='RED')
					  );
select name from salesperson 
where sales_id not in ( select sales_id from orders
                        left join company
						on orders.com_id = company.com_id 
						where company.name = 'RED');
s3 using case and having 
select s.name from salesperson s
left join orders o
using(sales_id)
left join company c
using(com_id) 
group by sales_id
having sum(case c.name when 'RED' THEN 1 else 0 end)=0;

select s.name from salesperson s
left join orders o
on s.sales_id = o.sales_id 
left join company c
on o.com_id = c.com_id 
group by s.sales_id 
having sum(case c.name when 'RED' THEN 1 ELSE 0 END) = 0;

s4 using not exist subquery
select s.name 
from salesperson s
where not exists ( 
                  select s.name 
				  from company c, orders o
				  where s.sales_id = o.sales_id 
				  and c.com_id = o.com_id 
				  and c.name = 'RED');

s5 using not in + in subquery 
select name 
from salesperson
where sales_id not in( 
                       select sales_id 
					   from orders 
					   where com_id in ( select com_id 
					                     from company
										 where name = 'RED'
										)
					 );
#608 Tree Nodes  1) constraints to define different nodes type 2) how to place 3 parallel types 
o1 
select t1.id, (...) as leaf
from tree t1, tree t2
s1 
select id, (case when p_id is null then 'Root'
                 when id not in (select ifnull(p_id,0) from tree) then 'Leaf'
				 else 'Inner' end) Type 
from tree;

select id, (case when p_id is null then 'Root'
                 when id not in (select ifnull(p_id,0) from tree) then 'Leaf'
				 else 'Inner' end) Type
from tree;

s2 
select distinct t1.id, (case when t1.p_id is null then 'Root'
                             when t2.id is null then 'Leaf'
							 else 'Inner' end) Type
from tree t1
left join tree t2
on t1.id = t2.p_id; 
s3 using union combining 3 types 
select id, 'Root' as Type from tree where p_id is null
union 
select id, 'Leaf' as Type from tree where id not in(select distinct p_id from tree where p_id is not null) and p_id is not null
union
select id, 'Inner' as Type from tree where id in(select distinct p_id from tree where p_id is not null) and p_id is not null order by id;

s4 using case flow control statement mysql 
select id as 'Id', case when tree.id = (select atree.id from tree atree where atree.p_id is null) then 'Root'
                        when tree.id in ( select atree.p_id from tree atree) then 'Inner'
						else 'Leaf'
				   end as Type
from tree
order by 'Id';
s5 using if 
select atree.id, if(isnull(atree.p_id), 
                          'Root',
						  if(atree.id in(select p_id from tree), 'Inner','Leaf')) Type
from tree atree
order by atree.id;
s6 
select distinct a.id, case when a.p_id is null then 'Root'
                           when b.id is null then 'Leaf'
						   else 'Inner'
					  end as Type
from tree a
left join tree b on a.id = b.p_id 
order by a.id;

s7
select id, ( case when p_id is null then 'Root'
                  when id in (select p_id from tree where p_id is not null) then 'Inner'
				  else 'Leaf'
			 end) as Type
from tree
group by id;

#610 triangle judgement 
s1 using if
select x,y,z,
if (x+y>z && x+z>y && y+z>x, 'YES','NO') triangle
from triangle 
s2 using case 
select x,y,z, (case when x+y > z and x+z>y and y+z > x then 'Yes' else 'No' end) as 'triangle'
from triangle;
#612 shortest distance in a plane    1) distance formula 2) comparasion 
s1 
select round(sqrt(min((pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)))),2) as shortest 
from point_2d p1
join point_2d on p1.x != p2.x or p1.y != p2.y;

better version 
select round(sqrt(min(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)))),2) as shortest
from point_2d p1
join point_2d p2 on (p1.x <= p2.x and p1.y < p2.y)
                 or (p1.x <= p2.x and p1.y > p2.y)
				 or (p1.x < p2.x and p1.y = p2.y);
#613 shortest distance on a line 
s1 join 
select min(abs(p1.x - p2.x)) as shortest
from point p1
join point p2 on p1.x != p2.x;
#614 followee and follower 
s1
select followee, follower, count(distinct follower) num
form follow
where followee in ( select follower 
                    from follow 
					group by follower),
group by followee
order by follower;
s2 
select f1.follower, count(distinct f2.follower) as num
from follow f1
inner join follow f2 on f1.follower = f2.followee
group by f1.follower;

#615 compare department average and company average salary
select pay_month, department_id, (case when avgs>ts then 'higher'
                                       when avgs<ts then 'lower'
									   else 'same' 
								  end) as comparison
from ( select date_format(pay_date, '%Y-%m') pay_month,
              department_id,
			  avg(amount) over(partition by date_format(pay_date, '%Y-%m')) ts,
			  avg(amount) over(partition by date_format(pay_date, '%Y-%m'), department_id) avgs
	   from salary s
	   left join employee e
	   on s.employee_id = e.employee_id
	  ) t1
group by pay_month, department_id 

				  

     









  
                             

      





        
	   
    

       
 

	  
     

	   	   			 	   





