-- Product Variant Trends    
SELECT
    t.date,
    pv.product_variant,
    SUM(t.quantity) AS total_units_sold,
    SUM(t.quantity * t.unit_price) AS total_revenue_per_product
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
GROUP BY t.date, pv.product_variant 
ORDER BY t.date, pv.product_variant;

SELECT
    pv.product_variant,
    SUM(t.quantity) AS total_units_sold,
    SUM(t.quantity * t.unit_price) AS total_revenue_per_product
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
GROUP BY  pv.product_variant 
ORDER BY  pv.product_variant;


-- Store + Product Variant    
EXPLAIN ANALYZE
SELECT 
	t.store_id, 
	pv.product_variant, 
	SUM(t.quantity) AS units_sold
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
GROUP BY t.store_id, pv.product_variant
ORDER BY units_sold DESC;