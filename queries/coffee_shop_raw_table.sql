DROP TABLE IF EXISTS analytics.coffee_shop_raw;

CREATE TABLE analytics.coffee_shop_raw (
    transaction_id VARCHAR(20),
    date DATE,
    time TIME,
    quantity INT,Í
	store_id NUMERIC(10,2),
    store_location VARCHAR(100),
	product_id NUMERIC(10,2),
    unit_price NUMERIC(10,2),
    category VARCHAR(50),
    product_name VARCHAR(100),
	product_detail VARCHAR(100)
);

