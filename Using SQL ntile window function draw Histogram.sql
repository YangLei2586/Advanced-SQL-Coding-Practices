---compare product sales by month
select date_format(order_date, '%b-%y') as order_date,
       sum(if(product='Pen', sale, null) as Pen,
	   sum(if(product='Paper',sale,null) as Paper
from sales
group by year(order_date), month(order_date), date_format(order_date,'%b-%y');

--- using width_bucket function to create buckets and histgram
select width_bucket(salary,70000,140000,5) as bucket,
       count(*) as cnt,
group by bucket
order by bucket;

---formate the bucket numbers to correspond to the salary bands
select 70000 + ((bucket-1)* (140000 - 70000)/5) ||'_'||(70000 + (bucket)*(140000 - 70000)/5),
       cnt from ( 
	   select width_bucket(salary,70000,140000,5) as bucket,
	          count(*) as cnt
	   from employee_salary
	   group by bucket
	   order by bucket) x;
--- using case for histograms
select case when salary between 75000 and 90000 then '75000-90000'
            when salary between 90000 and 120000 then '90000 - 120000'
			else '120000+'
	    end as salary_band,
	    count(*)
from employee_salary
group by 1;

---using ntile window function to find bucket widths
select ntile, min(salary), max(salary)
from ( select salary,
       ntile(4) over (order by salary)
	 ) x
group by ntile
order by ntile

--- sql windwo functions for cumulative histograms
select bucket, sum(cnt) over (order by bucket) 
  from (select width_bucket (salary, 70000, 140000,20) as bucket,
               count(*) as cnt
		from employee_salary
		group by bucket
		order by bucket) x;
with total as (select count(*) as cnt from employee_salary)
 select bucket, sum(cnt) over(order by bucket) / total.cnt
  from ( select width_bucket(salary,70000,140000,20) as bucket,
                count(*) as cnt
		 from employee_salary
		 group by bucket
		 order by bucket)x;

select width_bucket(salary, 70000,140000,5) as bucket,
      department,
	  count(*) as cnt
group by department, bucket
order by bucket, department