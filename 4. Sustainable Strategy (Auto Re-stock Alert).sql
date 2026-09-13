-- Sustainable Strategy (Auto Re-stock Alert)
-- Membandingkan EndInv (stok saat ini) dengan Reorder Point

WITH DynamicROP AS (
    SELECT 
        s.Brand,
        (AVG(s.SalesQuantity) * 10) + 50 AS calculated_rop -- Asumsi Lead Time 10 hari + Safety Stock 50
    FROM Sales2 s
    GROUP BY s.Brand
)
SELECT 
    e.Store,
    e.Brand,
    e.Description,
    e.onHand AS current_ending_stock,
    ROUND(r.calculated_rop, 0) AS reorder_point,
    CASE 
        WHEN e.onHand <= r.calculated_rop THEN 'CRITICAL: Trigger Purchase Order Immediately'
        WHEN e.onHand > (r.calculated_rop * 3) THEN 'WARNING: Overstock Trapping Working Capital'
        ELSE 'HEALTHY: Optimal Stock Level'
    END AS automated_action_trigger
FROM EndInv2 e
JOIN DynamicROP r ON e.Brand = r.Brand
WHERE e.onHand <= r.calculated_rop OR e.onHand > (r.calculated_rop * 3)
ORDER BY e.onHand ASC;
