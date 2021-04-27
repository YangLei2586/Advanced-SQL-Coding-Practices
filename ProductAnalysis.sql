select courseID, courseName,
sum(case when score between 85 and 100 then 1
         else 0
	end) as A
sum(case when score >=70 and score<85  then 1
         else 0
	end) as B
sum(case when score >=60 and score <70 then 1
         else 0
	end) as C
sum(case when score < 60 then 1
         else 0
	end) as D
from score as a right join course as b
on a.courseID = b.courseID
group by a.courseID, b.courseName

select courseId, courseName,
sum(case when score between 90 and 100 then 1
         else 0
	end) as A
sum(case when score >=80 and score <90 then 1
         else 0
	end) as B
sum(case when score >=70 and score <80 then 1
         else 0
	end) as C
sum(case when score>=60 and score <70  then 1
         else 0
	end) as D
sum(case when score<60 then 1
         else 0
	end) as F
from score as a right join course as b
on a.courseId = b.courseId
group by a.courseId, b.courseName

# select top 10 most selling products in the last 180 days 
# select display_name, top(10) total_transaction_value as top10      
## select top product_name or total_transaction ??
## total_transaction or sum of total_transaction??
## last 180 days
select top 10 display_name, sum(total_transaction_value) as sales
from transaction_90d as a, product as b
where a.product_id = b.id
and date 


# select top 10 most selling products in the last 180 days 

select product.display_name, sum(Transaction_90d.total_transaction_value) as sales
from product, Transaction_90d
where product.id = Transaction_90d.product_id
and date > DATE_SUB(CURDATE(), INTERVAL 90 days)
group by prodict.display_name
order by sales desc
limit 10

uion

select product.display_name, sum(Transaction_archive.total_transaction_value) as sales
from product, Transaction_Archive
where product.id = Transaction_Archive.product_id
and date > DATE_SUB(CURDATE(),INTERVAL 180 days)
group by product.display_name
order by sales desc
limit 10;

# select the name of top 5 customers based count of transaction numbers in the last 60 days
select first_name, last_name, count total_transaction_value as num_transactions
from customer, transaction_90d
where customer.id = transaction_90d.customer_id
and date > DATE_SUB(CURDATE(), interval 60 days)
group by product.id
order by num_transactions
limit 5;

# return product id and name for the least selling 10 products in the last 60 days
select product.id, display_name,sum(quantity) as total_quantity
from product, transaction_90d
where product.id = transaction_90d.product.id
and date > DATE_SUB(CURDATE(), interval 60 days)
group by product.id
order by total_quantity asc
limit 10;

# return category name, product name and count of quantity for the top 5 most selling products in each category in the last 30 days
select category.name, product.display_name, sum(transaction_90d.quantity) as count_quantity
from Category, Product, Transaction_90d
where category.id = product.category_id
and product.id = transaction_90d.product_id
and date > DATE_SUB(CURDATE(), interval 30 days)
group by category.name
order by count_quantity desc
limit 5;