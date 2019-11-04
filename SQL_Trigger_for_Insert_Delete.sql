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
