/*
=============================================================================
Cumulative Analysis
=============================================================================
Purpose:
    - Tracks sales momentum over time using cumulative and rolling metrics.

Highlights:
    1. Monthly total sales aggregated from fact_sales.
    2. Running total — cumulative sales from the beginning up to current month.
    3. Moving average — rolling avg of monthly sales up to current month.
=============================================================================
*/

SELECT
    DATETRUNC(MONTH, order_date)                       AS month,
    SUM(sales_amount)                                  AS total_sales,
    SUM(SUM(sales_amount)) OVER (
        ORDER BY DATETRUNC(MONTH, order_date)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                  AS running_total,
    AVG(SUM(sales_amount)) OVER (
        ORDER BY DATETRUNC(MONTH, order_date)
    )                                                  AS moving_avg
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);
