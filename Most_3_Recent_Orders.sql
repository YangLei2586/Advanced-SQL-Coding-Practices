
# 1) Return the product_name and total_transaction_amount for the top 10 most selling products in the last 180 days
# merge table transaction_90d and transaction_archive so that we can get and retrieve data for the last 180 days

with TransactionFull as 
( select * from transaction_90d
  union 
  select * from transaction_archive) 

select product.display_name, product.id, sum(TransactionFull.total_transaction_value) as sales
from Product, TransactionFull
where product.id = TransactionFull.product_id
and date > DATE_SUB(CURDATE(), INTERVAL 180 day)        
group by product.id
order by sales desc
limit 10;

# 2) return first_name, last_name, count of transaction as num_transactions for the top 5 customers in the last 60 days
select first_name, last_name, count total_transaction_value as num_transactions
from customer, transaction_90d
where customer.id = transaction_90d.customer_id
and date > DATE_SUB(CURDATE(), interval 60 day)
group by product.id
order by num_transactions desc
limit 5;

# 3) return product_id, product_name, total quantity for the least 10 selling products in the last 60 days
select product.id, display_name,sum(quantity) as total_quantity
from product, transaction_90d
where product.id = transaction_90d.product.id
and date > DATE_SUB(
, interval 60 day)
group by product.id
order by total_quantity asc
limit 10;

# 4) return category_name, product_name, count of quantity for the top 5 most selling products in each category in the last 30 days
select category.name, product.display_name, sum(transaction_90d.quantity) as count_quantity
from Category, Product, Transaction_90d
where category.id = product.category_id
and product.id = transaction_90d.product_id
and date > DATE_SUB(CURDATE(), interval 30 day)
group by category.name
order by count_quantity desc
limit 5;


# return the most recent orders for each product
select product_name, o.product_id, order_id, order_date
from Orders o left join Products p 
using (product_id) 
where (product_id, order_date) in 
( 
      select product_id, max(order_date) order_date
	  from Orders
	  group by product_id

)
order by product_name, product_id, order_id;

# another approach
select product_name, o.product_id, order_id, order_date
from Orders o left join Products p
on o.product_id = p.product_id
where(product_id, order_date) in
( 
    select product_id, max(order_date) order_date
	from Orders
	group by product_id

) 
order by product_name, product_id, order_id;

# return the result of the most recent 3 orders of each user 
select customer_name, customer_id, order_id, order_date
from 
(  
   select customer_id, order_id, order_date,
   dense_rank() over(partition by customer_id order by order_date desc) rnk
   from orders

) t

left join Customers 
on Customers.customer_id = t.customer_id
where rnk <= 3
order by name, customer_id, order_date desc;

## another similar approach 
select customer_name, customer_id, order_id, order_date
from 
(
    select customer_id, order_id, order_date,
	dense_rank over(partition by customer_id order by order_date desc) rnk 
	from orders
) t 
left join Customers
using(customer_id)
where rnk <=3
order by name, customer_id, order_date desc;


