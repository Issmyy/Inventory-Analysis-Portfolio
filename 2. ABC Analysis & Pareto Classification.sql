-- ABC Analysis & Pareto Classification
-- Mengelompokkan item berdasarkan kontribusi total Revenue dari Sales

WITH BrandRevenue AS (
	SELECT 
		Brand, 
        `Description`,
        SUM(SalesDollars) AS total_revenue,
        SUM(SalesQuantity) AS total_units_sold
	FROM Sales2
    GROUP BY Brand, `Description`
    ),
    ParetoCalculations AS (
    SELECT
		Brand, 
        `Description`,
        total_revenue,
        total_units_sold,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC, Brand ASC) AS running_total_revenue,
        SUM(total_revenue) OVER () AS grand_total_revenue
    FROM BrandRevenue
    )
    SELECT
		Brand,
        total_revenue,
        round((total_revenue / grand_total_revenue)* 100, 2) AS revenue_contribution_pct,
        Round((running_total_revenue / grand_total_revenue) * 100,2) AS cumulative_revenue_pct,
        CASE 
			WHEN (running_total_revenue / grand_total_revenue) <= 0.80 THEN 'Class A (HIgh Value)'
            WHEN (running_total_revenue / grand_total_revenue) <= 0.95 THEN 'Class B (Moderate Value)'
            ELSE 'Class C (Low Value/Optimization Target)'
			END AS abc_catagory
	FROM ParetoCalculations
        ORDER BY total_revenue DESC;