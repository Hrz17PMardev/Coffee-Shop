--- 3. Load data into the raw table
COPY analytics.coffee_shop_raw
FROM '/docker-entrypoint-initdb.d/data/coffee_shop/coffee-shop-sales-revenue.csv'
CSV HEADER DELIMITER '|' 
NULL 'NULL';