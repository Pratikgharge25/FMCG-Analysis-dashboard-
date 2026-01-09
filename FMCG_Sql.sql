create database FMCG;
use  FMCG;

 # 1) Total sales rewvenue
SELECT  
    SUM(quantity * unit_price) AS Total_Sales_Revenue
FROM fmcg_sales_transactions;

# 2) Total Quantity Sold
Select
sum(quantity) as total_quantity_sold
from fmcg_sales_transactions;

#3) Gross Profit
SELECT 
    SUM((unit_price - unit_cost) * quantity) AS Gross_Profit
FROM fmcg_sales_transactions;

#4) Gross Margin %
SELECT 
    (SUM((unit_price - unit_cost) * quantity) / SUM(unit_price * quantity)) * 100 
        AS Gross_Margin_Percentage
FROM fmcg_sales_transactions;

#5) Average selling price
SELECT 
    SUM(unit_price * quantity) / SUM(quantity) AS Average_Selling_Price
FROM fmcg_sales_transactions;

#6) Average Unit Cost
SELECT 
    SUM(unit_cost * quantity) / SUM(quantity) AS Average_Unit_Cost
FROM fmcg_sales_transactions;

#7) SKU Contribution %
SELECT 
  p.sku,
  SUM(s.quantity * s.unit_price) /
  (SELECT SUM(quantity * unit_price) FROM fmcg_sales_transactions) * 100
  AS sku_contribution_pct
FROM fmcg_sales_transactions s
JOIN fmcg_products_master p
  ON s.product_id = p.product_id
GROUP BY p.sku;

#8) Category Contribution to Sales
SELECT 
  p.category,
  SUM(quantity * unit_price) AS category_sales
FROM fmcg_sales_transactions s 
join fmcg_products_master p
  on s.product_id = p.product_id
GROUP BY p.category;

#9) Store-Level Sales Performance
SELECT 
  store_id,
  SUM(quantity * unit_price) AS store_sales
FROM fmcg_sales_transactions
GROUP BY store_id;

#10) Customer Basket Size
SELECT 
  AVG(item_count) AS avg_basket_size
FROM (
  SELECT sale_id, COUNT(product_id) AS item_count
  FROM fmcg_sales_transactions
  GROUP BY sale_id
) t;

#11) Customer Average Ticket Size
SELECT 
  AVG(order_value) AS avg_ticket_size
FROM (
  SELECT sale_id,
         SUM(quantity * unit_price) AS order_value
  FROM fmcg_sales_transactions
  GROUP BY sale_id
) t;

#12) Repeat Customer %
SELECT 
  (COUNT(DISTINCT customer_id) - COUNT(DISTINCT join_date)) /
  COUNT(DISTINCT customer_id) * 100 AS repeat_customer_pct
FROM fmcg_customer_master;

#13) New vs Returning Customers
SELECT
  CASE 
    WHEN sale_date = join_date THEN 'New'
    ELSE 'Returning'
  END AS customer_type,
  COUNT(*) AS total_customers
FROM fmcg_sales_transactions s
JOIN fmcg_customer_master c ON s.customer_id = c.customer_id
GROUP BY customer_type;

#14) Top 10 Products by Revenue
SELECT 
  product_id,
  SUM(quantity * unit_price) AS revenue
FROM fmcg_sales_transactions
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10;

#15) Top 10 Fast-Moving Items (By Quantity)
SELECT 
  product_id,
  SUM(quantity) AS total_qty
FROM fmcg_sales_transactions
GROUP BY product_id
ORDER BY total_qty DESC
LIMIT 10;

#16) Inventory Stock Coverage (Days of Stock)
#17)Stockout Risk Flag
#18)Reorder Alert
#19)Aging Inventory (Slow Moving)

#20)Promotion Uplift %
SELECT
  (SUM(CASE WHEN promo_id = 1 THEN quantity ELSE 0 END) /
   SUM(quantity)) * 100 AS promotion_uplift_pct
FROM fmcg_sales_transactions;

#21) Discount Impact on Sales
SELECT 
  SUM(discount_pct * quantity) AS total_discount_given
FROM fmcg_sales_transactions;




#22) Distributor Performance
SELECT 
  distributor_id,
  SUM(quantity * unit_price) AS distributor_sales
FROM fmcg_sales_transactions
GROUP BY distributor_id;

#23) Sales Rep Performance
SELECT 
  sales_rep_id,
  SUM(quantity * unit_price) AS rep_sales
FROM fmcg_sales_transactions
GROUP BY sales_rep_id;

#24)Fill Rate / Service Level
SELECT
    SUM(CASE WHEN return_flag = FALSE THEN 1 ELSE 0 END) AS total_successful_transactions,
    COUNT(*) AS total_transactions,
    (SUM(CASE WHEN return_flag = FALSE THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS service_level_pct
FROM FMCG_Sales_Transactions;

#25) Net Revenue After GST
SELECT 
  SUM(quantity * unit_price - gst_amount) AS net_revenue
FROM FMCG_Sales_Transactions;

#26)-- GST Contribution

SELECT 
    distributor_id,
    product_id,
    store_id,
    total_amount,
    gst_pct,
    (total_amount * gst_pct/ 100) AS gst_amount
FROM FMCG_Sales_Transactions;

#27) Product Launch Performance

select * from fmcg_products_master;

SELECT
    Product_id,
    Product_name,

    CASE
        WHEN DATEDIFF(CURDATE(), Launch_date) <= 30
             AND ((MRP - Cost_Price) * 100.0 / MRP) >= 25
        THEN 'Strong Launch'

        WHEN DATEDIFF(CURDATE(), Launch_date) <= 90
             AND ((MRP - Cost_Price) * 100.0 / MRP) BETWEEN 15 AND 25
        THEN 'Average Launch'

        ELSE 'Weak Launch'
    END AS Product_Launch_Performance

FROM fmcg_products_master;

#28 coloumn Channel Contribution (MT/GT/E-Comm)


SELECT
    channel_type,
    SUM(total_amount) AS channel_sales,
    ROUND(
        SUM(total_amount) * 100.0 /
        (SELECT SUM(total_amount)
         FROM FMCG_Sales_Transactions
         WHERE return_flag = 0),
        2
    ) AS channel_contribution_pct
FROM FMCG_Sales_Transactions
WHERE return_flag = 0
GROUP BY channel_type;

#29) Expiring Stock Value
SELECT
    SUM(quantity * unit_cost) AS expiring_stock_value
FROM FMCG_Sales_Transactions
WHERE exp_date BETWEEN CURDATE()
                  AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND return_flag = 0;
  
  
  #30) Return Rate
  
  SELECT
    ROUND(
        COUNT(CASE WHEN return_flag = 1 THEN sale_id END) * 100.0
        / COUNT(sale_id),
        2
    ) AS return_rate_pct
FROM FMCG_Sales_Transactions;