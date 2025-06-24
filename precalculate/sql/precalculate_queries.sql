-- Q001: Total revenue per nation based on lineitem extended price and discount.
SELECT n.n_name, n.n_total_revenue FROM nation n;;
-- Q002: Order count in 1992 per region.
SELECT r.r_name, r.r_order_count_1992 FROM region r;;
-- Q003: Number of orders per customer.
SELECT c.c_name, c.c_number_of_orders FROM customer c;;
-- Q004: Total amount spent by each customer.
SELECT c.c_name, c.c_total_spent FROM customer c;;
-- Q005: Average discount and lineitem count per order.
SELECT o.o_orderkey, o.o_total_lineitems, o.o_avg_discount FROM orders o;;
-- Q006: Total parts supplied by each supplier.
SELECT s.s_name, s.s_total_parts_supplied FROM supplier s;;
-- Q007: Total supply cost per supplier.
SELECT s.s_name, s.s_total_supply_cost FROM supplier s;;
-- Q008: Average supply cost per supplier.
SELECT s.s_name, s.s_avg_supply_cost FROM supplier s;;
-- Q009: Total part sales in the last 30 days per part.
SELECT p.p_name, p.p_total_sales_last_30_days FROM part p;;
-- Q010: Order count in 1993 per region.
SELECT r.r_name, r.r_order_count_1993 FROM region r;;
-- Q011: Order count in 1994 per region.
SELECT r.r_name, r.r_order_count_1994 FROM region r;;
-- Q012: Number of orders per customer using LEFT JOIN.
SELECT c.c_name, c.c_number_of_orders FROM customer c;;
-- Q013: Total parts supplied by each supplier.
SELECT s.s_name, s.s_total_parts_supplied FROM supplier s;;
-- Q014: Total supply cost per supplier (rounded).
SELECT s.s_name, s.s_total_supply_cost FROM supplier s;;
-- Q015: Average supply cost per supplier (rounded).
SELECT s.s_name, s.s_avg_supply_cost FROM supplier s;;
-- Q016: Number of lineitems per order.
SELECT o.o_orderkey, o.o_total_lineitems FROM orders o;;
-- Q017: Average discount per order.
SELECT o.o_orderkey, o.o_avg_discount FROM orders o;;
-- Q018: Revenue per nation based on extended price and discount.
SELECT n.n_name, n.n_total_revenue FROM nation n;;
-- Q019: Total part sales in last 30 days.
SELECT p.p_name, p.p_total_sales_last_30_days FROM part p;;
-- Q020: Total spending per customer.
SELECT c.c_name, c.c_total_spent FROM customer c;;
-- Q021: Total lineitems and avg discount for fulfilled orders by high-balance customers.
SELECT o.o_orderkey, o.o_total_lineitems, o.o_avg_discount FROM orders o JOIN customer c ON o.o_custkey = c.c_custkey WHERE o.o_orderstatus = 'F' AND c.c_acctbal > 1000;;
-- Q022: Number of orders per automobile segment customer since 1995.
SELECT c.c_name, c.c_number_of_orders FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey WHERE c.c_mktsegment = 'AUTOMOBILE' AND o.o_orderdate >= DATE '1995-01-01';;
-- Q023: Total supply cost for suppliers with negative balance and high quantity stock.
SELECT s.s_name, s.s_total_supply_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE s.s_acctbal < 0 AND ps.ps_availqty > 300;;
-- Q024: Sales for parts with recent shipments and medium discounts.
SELECT p.p_name, p.p_total_sales_last_30_days FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE l.l_shipdate >= CURRENT_DATE - INTERVAL 30 DAY AND l.l_discount BETWEEN 0.03 AND 0.07 GROUP BY p.p_name, p.p_total_sales_last_30_days;;
-- Q025: Nation revenue with recent shipping and low tax.
SELECT n.n_name, n.n_total_revenue FROM nation n JOIN supplier s ON n.n_nationkey = s.s_nationkey JOIN lineitem l ON s.s_suppkey = l.l_suppkey WHERE l.l_shipdate >= DATE '1994-01-01' AND l.l_tax < 0.05 GROUP BY n.n_name, n.n_total_revenue;;
-- Q026: Total lineitems and avg discount for urgent fulfilled orders.
SELECT o.o_orderkey, o.o_total_lineitems, o.o_avg_discount FROM orders o WHERE o.o_orderpriority = '1-URGENT' AND o.o_orderstatus = 'F';;
-- Q027: Number of open orders per customer from nation 5.
SELECT c.c_name, c.c_number_of_orders FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey WHERE c.c_nationkey = 5 AND o.o_orderstatus = 'O';;
-- Q028: Total parts supplied by suppliers with high balance and low quantity.
SELECT s.s_name, s.s_total_parts_supplied FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE s.s_acctbal > 1000 AND ps.ps_availqty < 200;;
-- Q029: Total supply cost from suppliers with economic-related comments.
SELECT s.s_name, s.s_total_supply_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE ps.ps_comment LIKE '%economy%';;
-- Q030: Sales for parts shipped by AIR with small quantities.
SELECT p.p_name, p.p_total_sales_last_30_days FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE l.l_shipmode = 'AIR' AND l.l_quantity < 10 GROUP BY p.p_name, p.p_total_sales_last_30_days;;
-- Q031: Nation revenue within a specific region.
SELECT n.n_name, n.n_total_revenue FROM nation n JOIN supplier s ON n.n_nationkey = s.s_nationkey JOIN lineitem l ON s.s_suppkey = l.l_suppkey WHERE n.n_regionkey = 1 GROUP BY n.n_name, n.n_total_revenue;;
-- Q032: Fulfilled orders in 1993 per region.
SELECT r.r_name, r.r_order_count_1993 FROM region r JOIN nation n ON r.r_regionkey = n.n_regionkey JOIN customer c ON n.n_nationkey = c.c_nationkey JOIN orders o ON c.c_custkey = o.o_custkey WHERE  o.o_orderstatus = 'F' GROUP BY r.r_name,  r.r_order_count_1993;;
-- Q033: Customer spending for furniture segment and specific clerks.
SELECT c.c_name, c.c_total_spent FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey WHERE o.o_clerk LIKE 'Clerk#000%' AND c.c_mktsegment = 'FURNITURE';;
-- Q034: Average cost from suppliers with promotional comments.
SELECT s.s_name, s.s_avg_supply_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE s.s_comment LIKE '%promotional%';;
-- Q035: Count of small shipments sent via MAIL per part.
SELECT p.p_name, p.p_total_sales_last_30_days FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE l.l_quantity < 5 AND l.l_shipmode = 'MAIL' GROUP BY p.p_name, p.p_total_sales_last_30_days;;
-- Q036: Total lineitems and average discount for low-priority orders with large quantities.
SELECT o.o_orderkey, o.o_total_lineitems, o.o_avg_discount FROM orders o JOIN lineitem l ON o.o_orderkey = l.l_orderkey WHERE o.o_shippriority = 0 AND l.l_quantity > 25 GROUP BY o.o_orderkey, o.o_total_lineitems, o.o_avg_discount;;
-- Q037: High priority orders from customers living on 'Street'.
SELECT c.c_name, c.c_number_of_orders FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey WHERE c.c_address LIKE '%Street%' AND o.o_orderpriority = '2-HIGH';;
-- Q038: Total supply cost from suppliers in nation 3 with affordable stock.
SELECT s.s_name, s.s_total_supply_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE s.s_nationkey = 3 AND ps.ps_supplycost < 500;;
-- Q039: Total truck-shipped sales for standard type parts.
SELECT p.p_name, p.p_total_sales_last_30_days FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE p.p_type LIKE 'STANDARD%' AND l.l_shipmode = 'TRUCK' GROUP BY p.p_name, p.p_total_sales_last_30_days;;
-- Q040: Revenue from nations with high balance suppliers and low tax items.
SELECT n.n_name, n.n_total_revenue FROM nation n JOIN supplier s ON n.n_nationkey = s.s_nationkey JOIN lineitem l ON s.s_suppkey = l.l_suppkey WHERE s.s_acctbal > 500 AND l.l_tax < 0.03 GROUP BY n.n_name, n.n_total_revenue;;
-- Q041: Top 10 customers by total spending in EUROPE
SELECT c.c_name, c.c_total_spent AS total_spent
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'EUROPE'
ORDER BY c.c_total_spent DESC
LIMIT 10;;
-- Q042: Top 10 suppliers by average discount given
SELECT s.s_name, s.s_avg_supply_cost AS avg_discount
FROM supplier s
ORDER BY s.s_avg_supply_cost DESC
LIMIT 10;;
-- Q043: Revenue per nation from parts sold
SELECT n.n_name, n.n_total_revenue AS revenue
FROM nation n
ORDER BY revenue DESC;;
-- Q044: Total number of orders per region in 1992
SELECT r.r_name, r.r_order_count_1992 AS num_orders
FROM region r;;
-- Q045: Top 10 parts by sales in the last 30 days
SELECT p.p_name, p.p_total_sales_last_30_days AS total_sales
FROM part p
ORDER BY total_sales DESC
LIMIT 10;;
-- Q046: Customers with more than 10 orders
SELECT c.c_name, c.c_number_of_orders AS num_orders
FROM customer c
WHERE c.c_number_of_orders > 10
ORDER BY num_orders DESC;;
-- Q047: Suppliers with highest supply cost
SELECT s.s_name, s.s_total_supply_cost AS total_cost
FROM supplier s
ORDER BY total_cost DESC
LIMIT 10;;
-- Q048: Total lineitems per order
SELECT o.o_orderkey, o.o_total_lineitems AS lineitem_count
FROM orders o;;
-- Q049: Average discount per order
SELECT o.o_orderkey, o.o_avg_discount AS avg_discount
FROM orders o;;
-- Q050: Total parts supplied per supplier
SELECT s.s_name, s.s_total_parts_supplied AS total_parts
FROM supplier s
ORDER BY total_parts DESC;;
-- Q051: Total quantity of parts shipped by supplier in ASIA
SELECT s.s_name, s.s_total_parts_supplied AS total_qty
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'ASIA'
ORDER BY total_qty DESC;;
-- Q052: Revenue by region in 1993
SELECT r.r_name, r.r_order_count_1993 AS revenue
FROM region r
ORDER BY revenue DESC;;
-- Q053: Top 5 parts by number of suppliers
SELECT p.p_name, p.p_total_sales_last_30_days AS num_suppliers
FROM part p
ORDER BY num_suppliers DESC
LIMIT 5;;
-- Q054: Customers with the highest number of lineitems
SELECT c.c_name, c.c_number_of_orders * o.o_total_lineitems AS lineitems
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
ORDER BY lineitems DESC
LIMIT 10;;
-- Q055: Revenue by supplier from EUROPE
SELECT s.s_name, s.s_total_supply_cost AS revenue
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'EUROPE'
ORDER BY revenue DESC
LIMIT 10;;
-- Q056: Orders per customer segment in 1994
SELECT c.c_mktsegment, SUM(c.c_number_of_orders) AS total_orders
FROM customer c
GROUP BY c.c_mktsegment
ORDER BY total_orders DESC;;
-- Q057: Top 10 revenue-generating orders
SELECT o.o_orderkey, o.o_total_lineitems * o.o_avg_discount AS revenue
FROM orders o
ORDER BY revenue DESC
LIMIT 10;;
-- Q058: Total part cost per region
SELECT r.r_name, SUM(s.s_total_supply_cost) AS total_cost
FROM region r
JOIN nation n ON r.r_regionkey = n.n_regionkey
JOIN supplier s ON n.n_nationkey = s.s_nationkey
GROUP BY r.r_name
ORDER BY total_cost DESC;;
-- Q059: Top 10 parts by revenue
SELECT p.p_name, p.p_total_sales_last_30_days AS revenue
FROM part p
ORDER BY revenue DESC
LIMIT 10;;
-- Q060: Orders by region for year 1994
SELECT r.r_name, r.r_order_count_1994 AS order_count
FROM region r;;
-- Q061: Customers who spent more than average total spending
SELECT c.c_name, c.c_total_spent
FROM customer c
WHERE c.c_total_spent > (
    SELECT AVG(c2.c_total_spent)
    FROM customer c2
);;
-- Q062: Suppliers who supplied more parts than the average
SELECT s.s_name, s.s_total_parts_supplied AS total_parts
FROM supplier s
WHERE s.s_total_parts_supplied > (
    SELECT AVG(s2.s_total_parts_supplied)
    FROM supplier s2
);;
-- Q063: Orders with more lineitems than average
SELECT o.o_orderkey, o.o_total_lineitems AS num_lineitems
FROM orders o
WHERE o.o_total_lineitems > (
    SELECT AVG(o2.o_total_lineitems)
    FROM orders o2
);;
-- Q064: Customers who placed more orders than average
SELECT c.c_name, c.c_number_of_orders
FROM customer c
WHERE c.c_number_of_orders > (
    SELECT AVG(c2.c_number_of_orders)
    FROM customer c2
);;
-- Q065: Suppliers with supply cost above average
SELECT s.s_name, s.s_total_supply_cost
FROM supplier s
WHERE s.s_total_supply_cost > (
    SELECT AVG(s2.s_total_supply_cost)
    FROM supplier s2
);;
-- Q066: Parts with higher than average recent sales
SELECT p.p_name, p.p_total_sales_last_30_days AS recent_sales
FROM part p
WHERE p.p_total_sales_last_30_days > (
    SELECT AVG(p2.p_total_sales_last_30_days)
    FROM part p2
);;
-- Q067: Regions with more orders than average in 1992
SELECT r.r_name, r.r_order_count_1992 AS num_orders
FROM region r
WHERE r.r_order_count_1992 > (
    SELECT AVG(r2.r_order_count_1992)
    FROM region r2
);;
-- Q068: Nations with above average revenue
SELECT n.n_name, n.n_total_revenue
FROM nation n
WHERE n.n_total_revenue > (
    SELECT AVG(n2.n_total_revenue)
    FROM nation n2
);;
-- Q069: Orders with average discount above global average
SELECT o.o_orderkey, o.o_avg_discount
FROM orders o
WHERE o.o_avg_discount > (
    SELECT AVG(o2.o_avg_discount)
    FROM orders o2
);;
-- Q070: Customers who spent more than any supplier supplied
SELECT c.c_name, c.c_total_spent
FROM customer c
WHERE c.c_total_spent > ALL (
    SELECT s.s_total_supply_cost
    FROM supplier s
);;
-- Q071: Customers with total spent higher than the highest supplier cost
SELECT c.c_name, c.c_total_spent
FROM customer c
WHERE c.c_total_spent > (
    SELECT MAX(s.s_total_supply_cost)
    FROM supplier s
);;
-- Q072: Suppliers supplying parts for all regions
SELECT s.s_name
FROM supplier s
WHERE (
    SELECT COUNT(DISTINCT r.r_regionkey)
    FROM region r
    JOIN nation n ON n.n_regionkey = r.r_regionkey
    WHERE n.n_nationkey = s.s_nationkey
) = (
    SELECT COUNT(*) FROM region
);;
-- Q073: Parts whose total sales are above average in last 30 days
SELECT p.p_name, p.p_total_sales_last_30_days
FROM part p
WHERE p.p_total_sales_last_30_days > (
    SELECT AVG(p2.p_total_sales_last_30_days)
    FROM part p2
);;
-- Q074: Nations with revenue greater than at least one other nation
SELECT n.n_name, n.n_total_revenue
FROM nation n
WHERE n.n_total_revenue > (
    SELECT MIN(n2.n_total_revenue)
    FROM nation n2
);;
-- Q075: Orders with more lineitems than any other
SELECT o.o_orderkey, o.o_total_lineitems AS lineitem_count
FROM orders o
WHERE o.o_total_lineitems > ALL (
    SELECT o2.o_total_lineitems
    FROM orders o2
);;
-- Q076: Suppliers whose average supply cost is above global average
SELECT s.s_name, s.s_avg_supply_cost
FROM supplier s
WHERE s.s_avg_supply_cost > (
    SELECT AVG(s2.s_avg_supply_cost)
    FROM supplier s2
);;
-- Q077: Suppliers whose total cost is higher than any customer spent
SELECT s.s_name, s.s_total_supply_cost
FROM supplier s
WHERE s.s_total_supply_cost > ALL (
    SELECT c.c_total_spent
    FROM customer c
);;
-- Q078: Orders with average discount lower than any other
SELECT o.o_orderkey, o.o_avg_discount
FROM orders o
WHERE o.o_avg_discount < ALL (
    SELECT o2.o_avg_discount
    FROM orders o2
);;
-- Q079: Customers whose total spending is more than the total spending of all customers in ASIA
SELECT c.c_name, c.c_total_spent
FROM customer c
WHERE c.c_total_spent > (
    SELECT SUM(c2.c_total_spent)
    FROM customer c2
    JOIN nation n ON c2.c_nationkey = n.n_nationkey
    JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE r.r_name = 'ASIA'
);;
-- Q080: Suppliers who supply more parts than any customer has ordered
SELECT s.s_name, s.s_total_parts_supplied AS total_supplied
FROM supplier s
WHERE s.s_total_parts_supplied > ALL (
    SELECT c.c_number_of_orders * MAX(o.o_total_lineitems)
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_number_of_orders
);;
-- Q081: Rank customers by total spending using a window function
SELECT c.c_name, c.c_total_spent, RANK() OVER (ORDER BY c.c_total_spent DESC) AS spending_rank
FROM customer c
LIMIT 10;;
-- Q082: Find top supplier per region by supply cost
WITH regional_supply AS (
    SELECT r.r_name, s.s_name, s.s_total_supply_cost AS total_cost
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN supplier s ON n.n_nationkey = s.s_nationkey
)
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY r_name ORDER BY total_cost DESC) AS rank
    FROM regional_supply
)
WHERE rank = 1;;
-- Q083: Calculate running total of part sales
SELECT p.p_name, p.p_total_sales_last_30_days AS sales,
       SUM(p.p_total_sales_last_30_days) OVER (ORDER BY p.p_total_sales_last_30_days DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM part p
ORDER BY sales DESC
LIMIT 10;;
-- Q084: Find average discount per customer order using a CTE
SELECT c.c_name, o.o_orderkey, o.o_avg_discount AS avg_discount
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_avg_discount > 0.05
ORDER BY avg_discount DESC;;
-- Q085: Determine most common container type per part type
SELECT p_type, p_container
FROM (
    SELECT p.p_type, p.p_container,
           RANK() OVER (PARTITION BY p.p_type ORDER BY COUNT(*) DESC) AS rnk
    FROM part p
    GROUP BY p.p_type, p.p_container
)
WHERE rnk = 1;;
-- Q086: Compute total and average spending by region using window
SELECT r.r_name,
       SUM(c.c_total_spent) AS total_region_spent,
       AVG(c.c_total_spent) AS avg_region_spent
FROM region r
JOIN nation n ON r.r_regionkey = n.n_regionkey
JOIN customer c ON n.n_nationkey = c.c_nationkey
GROUP BY r.r_name;;
-- Q087: Rank suppliers by average supply cost using dense_rank
SELECT s.s_name, s.s_avg_supply_cost AS avg_cost,
       DENSE_RANK() OVER (ORDER BY s.s_avg_supply_cost DESC) AS cost_rank
FROM supplier s;;
-- Q088: Find top 3 customers by orders per market segment
SELECT *
FROM (
    SELECT c.c_mktsegment, c.c_name, c.c_number_of_orders AS order_count,
           ROW_NUMBER() OVER (PARTITION BY c.c_mktsegment ORDER BY c.c_number_of_orders DESC) AS rank
    FROM customer c
)
WHERE rank <= 3;;
-- Q089: Average discount per region over time using CTE
WITH discounts AS (
    SELECT r.r_name, o.o_orderdate, l.l_discount
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN customer c ON n.n_nationkey = c.c_nationkey
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
)
SELECT r_name, DATE_PART('year', o_orderdate) AS order_year,
       AVG(l_discount) AS avg_discount
FROM discounts
GROUP BY r_name, order_year
ORDER BY r_name, order_year;;
-- Q090: Compare each supplier's cost to regional average using window
WITH supplier_costs AS (
    SELECT r.r_name, s.s_name, s.s_total_supply_cost AS total_cost
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN supplier s ON n.n_nationkey = s.s_nationkey
)
SELECT *,
       AVG(total_cost) OVER (PARTITION BY r_name) AS regional_avg
FROM supplier_costs;;
-- Q091: Identify the region with the most orders over all time
SELECT *
FROM (
    SELECT r.r_name, SUM(r.r_order_count_1992 + r.r_order_count_1993 + r.r_order_count_1994) AS total_orders,
           RANK() OVER (ORDER BY SUM(r.r_order_count_1992 + r.r_order_count_1993 + r.r_order_count_1994) DESC) AS rank
    FROM region r
    GROUP BY r.r_name
)
WHERE rank = 1;;
-- Q092: Calculate moving average of part sales
SELECT p.p_name, p.p_total_sales_last_30_days AS sales,
       AVG(p.p_total_sales_last_30_days) OVER (ORDER BY p.p_total_sales_last_30_days DESC
                                               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM part p
ORDER BY sales DESC;;
-- Q093: Detect customers with spending significantly above their segment average
WITH segment_avg AS (
    SELECT c.c_mktsegment, AVG(c.c_total_spent) AS avg_segment_spent
    FROM customer c
    GROUP BY c.c_mktsegment
)
SELECT c.c_name, c.c_mktsegment, c.c_total_spent, sa.avg_segment_spent
FROM customer c
JOIN segment_avg sa ON c.c_mktsegment = sa.c_mktsegment
WHERE c.c_total_spent > 1.5 * sa.avg_segment_spent;;
-- Q094: Top 3 parts per brand by revenue
SELECT *
FROM (
    SELECT p.p_brand, p.p_name, p.p_total_sales_last_30_days AS revenue,
           ROW_NUMBER() OVER (PARTITION BY p.p_brand ORDER BY p.p_total_sales_last_30_days DESC) AS rank
    FROM part p
)
WHERE rank <= 3;;
-- Q095: Average and max discount per supplier
SELECT s.s_name,
       AVG(l.l_discount) AS avg_discount,
       MAX(l.l_discount) AS max_discount
FROM supplier s
JOIN lineitem l ON s.s_suppkey = l.l_suppkey
GROUP BY s.s_name;;
-- Q096: Cumulative order count by region by year
WITH region_orders AS (
    SELECT r.r_name AS r_name, 1992 AS year, r.r_order_count_1992 AS order_count FROM region r
    UNION ALL
    SELECT r.r_name, 1993, r.r_order_count_1993 FROM region r
    UNION ALL
    SELECT r.r_name, 1994, r.r_order_count_1994 FROM region r
)
SELECT r_name, year, order_count,
       SUM(order_count) OVER (PARTITION BY r_name ORDER BY year) AS cumulative_orders
FROM region_orders
ORDER BY r_name, year;;
-- Q097: Detect nations with increasing year-over-year revenue
WITH nation_yearly AS (
    SELECT n.n_name, DATE_PART('year', l.l_shipdate) AS year,
           SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
    FROM nation n
    JOIN supplier s ON n.n_nationkey = s.s_nationkey
    JOIN lineitem l ON s.s_suppkey = l.l_suppkey
    GROUP BY n.n_name, year
),
ranked AS (
    SELECT *, LAG(revenue) OVER (PARTITION BY n_name ORDER BY year) AS prev_revenue
    FROM nation_yearly
)
SELECT * FROM ranked
WHERE revenue > prev_revenue;;
-- Q098: Supplier share of total cost in region
WITH supplier_costs AS (
    SELECT r.r_name, s.s_name, s.s_total_supply_cost AS total_cost
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN supplier s ON n.n_nationkey = s.s_nationkey
)
SELECT *, total_cost * 1.0 / SUM(total_cost) OVER (PARTITION BY r_name) AS cost_share
FROM supplier_costs;;
-- Q099: Find customers whose rank in orders differs from rank in spending
WITH ranked_customers AS (
    SELECT c.c_name,
           RANK() OVER (ORDER BY c.c_number_of_orders DESC) AS order_rank,
           RANK() OVER (ORDER BY c.c_total_spent DESC) AS spend_rank
    FROM customer c
)
SELECT *
FROM ranked_customers
WHERE ABS(order_rank - spend_rank) > 5;;
-- Q100: Identify top customer per region by total spent
SELECT *
FROM (
    SELECT r.r_name, c.c_name, c.c_total_spent AS spent,
           ROW_NUMBER() OVER (PARTITION BY r.r_name ORDER BY c.c_total_spent DESC) AS rank
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN customer c ON n.n_nationkey = c.c_nationkey
)
WHERE rank = 1;;
