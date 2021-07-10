#262 Trips and Users
solution 1
select Request_at 'Day',
       round(avg(Status != 'completed'),2) 'Cancellation Rate'
from Trips t left join Users u
on t.Client_Id = u.Users_id
where Banned = 'No'
and Request_at between '2013-10-01' and '2013-10-03'
group by Request_at;

solution 2
select t.request_at Day,
       round(count(case when t.status like 'cancelled%' then 1 end) / count(*), 2) as 'Cancellation Rate'
from Users c Inner Join Trips t 
             Inner Join Users d
on c.users_id = t.client_id 
and t.driver_id = d.users_id 
where c.banned = 'No'
and d.banned = 'No'
and t.request_at Between '2013-10-01' and '2013-10-03'
group by Day;
#511 Game players analysis
1 find out the first login date for every player
select min(event_date) first_login, player_id
from Activity
group by player_id;
2 find out the device for first login   1) how to define first login in this case >> using subquery to give min(date)
solution 1
select player_id, device_id
from activity
where (player_id, event_date) in 
      (  
	    select player_id, min(event_date)
		from activity
		group by player_id);
solution 2
select a.player_id, a.device_id
from Activity a,
     ( select *, min(event_date) mindate
	   from Activity
	   group by player_id
	 ) t
where a.player_id = t.player_id 
and a.event_date = t.mindate;
3 find out how many games played so far 
select a1.player_id, a1.event_date,
    sum(a2.games_played) games_played_so_far
from Activity a1, Acitvity a2
where a1.player_id = a2.player_id
and a1.event_date >= a2.event_date
group by a1.player_id, a1.event_date;

4 fraction for players played at least 1 since first login and played
select round(count(*) /(select count(distinct player_id) from Activity), 2) fraction
from Activity a
where (player_id, event_date) in (
                                   select player_id, date_add(min(event_date),interval 1 day) frist_day
								   from Activity
								   group by player_id
								 );
                                
#618 Students report by geography pivot
s1 using case and row_number
select 
       max(case when continent = 'America' then name end) as America,
	   max(case when continent = 'Asia'    then name end) as Asia,
	   max(case when continent = 'Europe'  then name end) as Europe
from (select *, row_number() over(partition by continent order by name) as row_id from students) as t
group by row_id;

s2 using session variables
select max(America) as America, Max(Asia) as Asia, Max(Europe) as Europe
from (
      select 
	         case when continent = 'America' then @r1 + 1
			      when continent = 'Asia'    then @r2 + 1
				  when continent = 'Europe'  then @r3 + 1 End row_id,
			 case when continent = 'America' then name end America,
			 case when continent = 'Asia'    then name end Asia,
			 case when continent = 'Europe'  then name end Europe
	  from student, (select @r1 :=0, @r2 :=0, @r3 :=0) tmp
	  order by name ) t
group by row_id;

s3 using row_id
select America, Asia, Europe
from  (select @as:=0, @am:=0,@eu:=0) t,
      (select 
	         @as:=@as + 1 as asid, name as Asia
	   from student
	   where continent = 'Asia'
	   order by Asia) as t1
	   right join 
	   (select 
	         @am:=@am + 1 as amid, name as America
		from student
		where continent = 'America'
		order by America) as t2 on asid=amid
		left join
		(select 
		     @eu:=@eu + 1 as euid, name as Europe
		 from student
		 where continent = 'Europe'
		 order by Europe) as t3 on amid = euid;

#619 biggest number appears once  1) why o1 not working why have to subquery
o1 
select max(num) num
from my_numbers
group by num
having count(num) = 1
order by num desc;
s1
select max(num) num
from ( select num
       from my_numbers
	   group by num
	   having count(num) = 1) as t;

s2 using union
select num
from my_numbers
group by num
having count(*) = 1
union all
select null
order by num desc
limit 1;

s3  1) why inside alone does not work
select (
        select ifnull(num,null)
		from my_numbers
		group by num
		having coutn(*) = 1
		order by num desc
		limit 1
		) as num;

#620 Not borning movies 1) odd-numbered ID >> mod(id,2)=1 or (id%2)!=0
o1
select id,movie,description,rating
from Cinema
where mod(id,2)=1 
and decription != 'boring'
order by rating desc;

#626 Exchange seats    1) number of students is odd no need to change the last one 2) how to exchange adjacent seats
s1    1) need to know based on the total number of seats odd or even first
select ( case 
              when mod(id,2) != 0 and counts != id then id + 1
			  when mod(id,2) != 0 and counts != id then id -1 
			  else id -1 
		 end ) as id, student
from seat, (select 
                  count(*) as counts
			from seat) as seat_counts
order by id asc;

#627 Swap salary  1) single update statement no temp tables
s1 
update salary
set 
    sex = case sex 
	      when 'm' then 'f'
		  else 'm'
	end;

#1045 customers who bought all products 1) bought all products >> comparaing counts of two product keys
s1
select customer_id
from customer c
group by customer_id
having count(distinct product_key) = (select count(distinct product_key) from product);

#1050 actors and directors who cooperated at least three times  1) how to caculate times 
s1
select actor_id, director_id
from ActorDirector
group by actor_id, director_id
having count(1) >=3;
s2
select actor_id, director_id
from ActorDirector
group by actor_id,director_id
having count(distinct timestamp) >=3;

#1068 prodcut sales analysis I
s1  1) differences to join on >> inner join equavilent 
select s.sale_id,p.product_name, s.year,s.price
from Sales s, Product p
where p.product_id = s.product_id;

#1069 product sales analsysis II
select product_id, sum(quantity) as total_quantity
from sales
group by product_id;

#1070 product sales analysis III 1) how to select the first year for each product min(year)?
o1 unaggregated columns will not match the min(year) of each product_id
select product_id, min(year) as first_year, quantity, price
from Sales a 
group by product_id;
s1
select product_id, year as first_year, quantity, price
from sales
where (product_id, year) in (select product_id, min(year) as year from sales group by product_id);

                              









		


