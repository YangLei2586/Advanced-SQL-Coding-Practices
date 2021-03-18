# A query that gets the number of retained users per month. In this case retention for a given month is defined as the 
# number of users who logged in that month who also logged in the immediately previous month.

with DistinctMonthlyUsers AS (
/* For each month, compute the set of users having logins */
     select distinct date_trunc('month',date) as month_timestamp, user_id
	 from logins
	 )

	 select CurrentMonth.month_timestamp month_timestamp,
	        count(PriorMonth.user_id) as retained_user_count
	 from DistinctMonthlyUsers as CurrentMonth
	 left join 
	      DistinctMonthlyUsers as PriorMonth
	 on CurrentMonth.month_timestamp = PriorMonth.month_timestamp + Interval ' 1 month'
	 and CurrentMonth.user_id = PriorMonth.user_id
	 group by CurrentMonth.month_timestamp



