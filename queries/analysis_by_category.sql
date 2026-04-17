-- Sales by Category per Store
SELECT 
	c.category, 
	t.store_id, 
	location_name,
	SUM(t.quantity*t.unit_price) AS revenue_per_category
FROM analytics.transactions t
JOIN analytics.stores s ON t.store_id = s.store_id
JOIN analytics.store_locations sl ON sl.location_id = s.location_id
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
JOIN analytics.products p ON pv.product_id = p.product_id
JOIN analytics.categories c ON p.category_id = c.category_id
GROUP BY t.store_id, c.category, location_name 
;


-- Category Trends Over Time
SELECT 
	c.category, 
	t.date, 
	SUM(t.quantity*t.unit_price) AS revenue_by_category_and_date
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
JOIN analytics.products p ON pv.product_id = p.product_id
JOIN analytics.categories c ON p.category_id = c.category_id
GROUP BY c.category, t.date
;