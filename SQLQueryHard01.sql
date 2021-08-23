#602 Human traffic of Stadium display records wiht 3 or more rows with consecutive Id and people 100
s1
select s1.* 
from stadium s1, stadium s2, stadium s3
where ( (s1.id + 1 = s2.id and s1.id + 2 = s3.id)
       or (s1.id -1 = s2.id and s1.id + 1= s3.id)
	   or (s1.id -2 = s2.id and s1.id - 1 = s3.id)
	  )
and s1.people >= 100
and s2.people >= 100
and s3.people >= 100

group by s1.id;

select s1.*
from stadium s1, stadium s2, stadium s3
where ( (s1.id + 1 = s2.id and s1.id + 2 = s3.id)
        or (s1.id - 1 =s2.id and s1.id + 1 = s3.id)
		or (s1.id - 2 = s3.id and s1.id - 1 = s3.id)
	  ) 
and s1.people >= 100
and s2.people >= 100
and s3.people >= 100
group by s1.id;

#1336 Number of transactions per visit  1) how to count for transaction numbers 1, 2, 3? 
S1 CTE and Window function 
with t1 as ( select count(t.transaction_date) as transactions_count 
             from visits v
             left join Transaction T on v.user_id = t.user_id and v.visit_date = t.transaction_date
			 group by v.user_id, v.visit_date),
	 t2 as ( select row_number() over() rn 
	         from transactions 
			 union 
			 select 0 rn ) 
select distinct t2.rn as transactions_count, case when t1.transactions_count is null then 0 else count(t1.transactions_count) over(partition by t1.transactions_count)
                                             end as visits_count 
from t2 
left join t1 on t2.rn = t1.transactions_count 
where t2.rn <= (select max(transactions_count) from t1)
order by transactions_count;

S2 CTE 
with t as (select if(t.transaction_date is null, 0, count(*)) cnt
           from visits v
		   left join transactions t
		   on v.user_id = t.user_id and v.visit_date = t.transaction_date
		   group by v.user_id, v.visit_date),
	 t1 as (select cnt, count(*) v_cnt
	        from t
			group by cnt),
	 t2 as (select row_number() over() rn
	        from transactions
			union
			select 0 rn)
select t2.rn transaction_count, ifnull(t1.v_cnt,0) visits_count
from t2
left join t1
on t2.rn = t1.rn
where t2.rn <=(select max(cnt) from t1)
order by t2.rn;
 
#1369 Get the second most recent activity 1) get second most date max() lag/lead 2) no second return the only one 
S1 
select username, activity, startDate, endDate
from ( select *, count(activity) over(partition by username) cnt,
       row_number() over(partition by username order by startdate desc) n 
	   from UserActivity) tb1
where n=2 or cnt<2;

S2 
select username, activity, startdate, enddate 
from ( select username, activity, startdate, enddate, row_number()over(partition by username order by startdate desc) as rn 
       from UserActitivy) tb1
where tb1.rn = 2
union 
select username,activity, startdate, enddate
from UserActivity
where username in ( select username
                    from activity
					group by username
					having count(*)=1);

S1 
select username, activity, startdate, enddate
from ( select *,
       row_number() over(partition by username order by startdate desc) n, 
	   count(activity) over(partition by username) cnt
	   from UserActivity) tb
where n= 2 or cnt<2;

select username, startdate, enddate, activity
from ( select *,
       row_number() over(partition by username order by startdate desc) n,
	   count(activity) over(partition by username) cnt
	   from UserActitivy) tb
where n=2 or cnt<2;

select username,activity, startdate,enddate
from (select *,
      row_number() over(partition by username order by startdate desc) n,
	  count(activity) over(partition by username) cnt
	  from UserActivity) tb
where n=2 or cnt<2;

select username, activity,startdate, enddate
from (select *,
      row_number()over(partition by username order by startdate desc) n,
	  count(activity) over(partition by username) cnt
	  from UserActivity) tb
where n=2 or cnt<2;

#1384 Total sales amount by year 1) get total sales days 
S1
select a.product_id, b.product_name, a.report_year, a.total_amount
from ( select product_id, '2018' as report_year,
              average_daily_sales * (datediff(least(period_end,'2018-12-31'),greatest(period_start,'2018-01-01')) + 1)  as total_amount
	   from Sales
	   where year(period_start) = 2018 or year(period_end)=2018
	   
	   union all 

	   select product_id, '2019' as report_year,
	         average_daily_sales *( datediff(least(period_end, '2019-12-31'), greast(period_start,'2019-01-01')) + 1) as total_amount
	   from Sales 
	   where year(period_start)<=2019 and year(period_end)>=2019;

	   union all 

	   select product_id, '2020' as report_year,
	          average_daily_sales * (datediff(least(period_end, '2020-12-31'), greast(period_start,'2020-01-01')) +1) as total_amount
	   ) a
left join Product b
on a.product_id = b.product_id
order by a.product_id, a.report_year;




     


