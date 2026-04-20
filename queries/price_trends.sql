-- Average Unit Price Trends
SELECT 
	*
FROM analytics.price_trends;

SELECT
	product_variant, 
	date,
	avg_price
FROM analytics.price_trends pt
JOIN analytics.products_variants pv ON pt.product_variant_id = pv.product_variant_id
WHERE pt.product_variant_id = 82          -- I Need My Bean! Diner mug
ORDER BY date
;

-- Customer Basket Analysis
EXPLAIN ANALYZE
SELECT DISTINCT
	transaction_id,
	product_variant
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
GROUP BY transaction_id, product_variant
;