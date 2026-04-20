-- Sales by Store per Day
SELECT 
	tr.store_id, 
	date, 
	SUM(quantity*unit_price) AS revenue_by_store_per_day
FROM analytics.transactions tr
GROUP BY tr.store_id, date
;

-- Performance per Day of Week
SELECT 
    EXTRACT(DOW FROM date) AS day_of_week,
    TO_CHAR(date, 'Day') AS weekday_name,
    SUM(quantity * unit_price) AS total_sales,
    SUM(quantity) AS total_units_sold,
    COUNT(DISTINCT transaction_id) AS num_transactions
FROM analytics.transactions
GROUP BY day_of_week, weekday_name
ORDER BY total_sales DESC;

-- Performance by Store/Location per Day of Week
SELECT 
    s.store_id,
    sl.location_name,
    EXTRACT(DOW FROM t.date) AS day_of_week,
    TO_CHAR(t.date, 'Day') AS weekday_name,
    SUM(t.quantity * t.unit_price) AS total_sales,
    SUM(t.quantity) AS total_units_sold,
    COUNT(DISTINCT t.transaction_id) AS num_transactions
FROM analytics.transactions t
JOIN analytics.stores s ON t.store_id = s.store_id
JOIN analytics.store_locations sl ON s.location_id = sl.location_id
GROUP BY s.store_id, sl.location_name, day_of_week, weekday_name
ORDER BY s.store_id, day_of_week;

-- Store Location + Date        
EXPLAIN ANALYZE
SELECT 
	sl.location_name, 
	t.date, 
	SUM(t.quantity * t.unit_price) AS total_revenue
FROM analytics.transactions t
JOIN analytics.stores s ON t.store_id = s.store_id
JOIN analytics.store_locations sl ON s.location_id = sl.location_id
WHERE t.date BETWEEN '2023-01-01' AND '2023-01-31'
GROUP BY sl.location_name, t.date
ORDER BY sl.location_name
;

-- Peak Hours Analysis
SELECT 
	*
FROM analytics.hourly_sales	
ORDER BY total_sales DESC
;

-- Peak hours by stores
SELECT 
	location_name,
	EXTRACT(HOUR FROM time) AS hour, 
	SUM(quantity*unit_price) AS total_sales
FROM analytics.transactions t
JOIN analytics.sales_by_store slbst ON t.store_id = slbst.store_id
GROUP BY location_name, hour
ORDER BY total_sales DESC
LIMIT 10
;