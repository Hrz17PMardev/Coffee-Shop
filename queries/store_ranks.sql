-- Store Performance Ranking
SELECT 
	location_name,
	quantity_rank,
	sold_quantity_per_store(total_units_sold) AS seller_by_quantity,
	revenue_rank,
	store_revenue_performance(total_revenue) AS seller_by_revenue
FROM store_ranks_by_quantity_revenue;