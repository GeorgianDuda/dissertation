-- Q001: Total revenue per nation based on lineitem extended price and discount.
SELECT n.n_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue FROM nation n JOIN supplier s ON n.n_nationkey = s.s_nationkey JOIN lineitem l ON s.s_suppkey = l.l_suppkey GROUP BY n.n_name;;
-- Q002: Order count in 1992 per region.
SELECT r.r_name, COUNT(*) AS order_count_1992 FROM region r JOIN nation n ON r.r_regionkey = n.n_regionkey JOIN customer c ON n.n_nationkey = c.c_nationkey JOIN orders o ON c.c_custkey = o.o_custkey WHERE EXTRACT(YEAR FROM o.o_orderdate) = 1992 GROUP BY r.r_name;;
-- Q003: Number of orders per customer.
SELECT c.c_name, COUNT(*) AS number_of_orders FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey GROUP BY c.c_name;;
-- Q004: Total amount spent by each customer.
SELECT c.c_name, SUM(o.o_totalprice) AS total_spent FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey GROUP BY c.c_name;;
-- Q005: Average discount and lineitem count per order.
SELECT o.o_orderkey, COUNT(*) AS total_lineitems, AVG(l.l_discount) AS avg_discount FROM orders o JOIN lineitem l ON o.o_orderkey = l.l_orderkey GROUP BY o.o_orderkey;;
-- Q006: Total parts supplied by each supplier.
SELECT s.s_name, COUNT(*) AS total_parts_supplied FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey GROUP BY s.s_name;;
-- Q007: Total supply cost per supplier.
SELECT s.s_name, SUM(ps.ps_supplycost) AS total_supply_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey GROUP BY s.s_name;;
-- Q008: Average supply cost per supplier.
SELECT s.s_name, AVG(ps.ps_supplycost) AS avg_supply_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey GROUP BY s.s_name;;
-- Q009: Total part sales in the last 30 days per part.
SELECT p.p_name, SUM(l.l_extendedprice) AS total_sales FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE l.l_shipdate >= CURRENT_DATE - INTERVAL 30 DAY GROUP BY p.p_name;;
-- Q010: Order count in 1993 per region.
SELECT r.r_name, COUNT(*) AS order_count_1993 FROM region r JOIN nation n ON r.r_regionkey = n.n_regionkey JOIN customer c ON n.n_nationkey = c.c_nationkey JOIN orders o ON c.c_custkey = o.o_custkey WHERE EXTRACT(YEAR FROM o.o_orderdate) = 1993 GROUP BY r.r_name;;
-- Q011: Order count in 1994 per region.
SELECT r.r_name, COUNT(*) AS order_count_1994 FROM region r JOIN nation n ON r.r_regionkey = n.n_regionkey JOIN customer c ON n.n_nationkey = c.c_nationkey JOIN orders o ON c.c_custkey = o.o_custkey WHERE EXTRACT(YEAR FROM o.o_orderdate) = 1994 GROUP BY r.r_name;;
-- Q012: Number of orders per customer using LEFT JOIN.
SELECT c.c_name, COUNT(DISTINCT o.o_orderkey) AS order_count FROM customer c LEFT JOIN orders o ON c.c_custkey = o.o_custkey GROUP BY c.c_name;;
-- Q013: Total parts supplied by each supplier.
SELECT s.s_name, COUNT(ps.ps_partkey) AS parts_supplied FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey GROUP BY s.s_name;;
-- Q014: Total supply cost per supplier (rounded).
SELECT s.s_name, ROUND(SUM(ps.ps_supplycost), 2) AS total_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey GROUP BY s.s_name;;
-- Q015: Average supply cost per supplier (rounded).
SELECT s.s_name, ROUND(AVG(ps.ps_supplycost), 2) AS avg_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey GROUP BY s.s_name;;
-- Q016: Number of lineitems per order.
SELECT o.o_orderkey, COUNT(l.l_linenumber) AS num_items FROM orders o JOIN lineitem l ON o.o_orderkey = l.l_orderkey GROUP BY o.o_orderkey;;
-- Q017: Average discount per order.
SELECT o.o_orderkey, ROUND(AVG(l.l_discount), 3) AS avg_disc FROM orders o JOIN lineitem l ON o.o_orderkey = l.l_orderkey GROUP BY o.o_orderkey;;
-- Q018: Revenue per nation based on extended price and discount.
SELECT n.n_name, ROUND(SUM(l.l_extendedprice * (1 - l.l_discount)), 2) AS revenue FROM nation n JOIN supplier s ON n.n_nationkey = s.s_nationkey JOIN lineitem l ON s.s_suppkey = l.l_suppkey GROUP BY n.n_name;;
-- Q019: Total part sales in last 30 days.
SELECT p.p_name, SUM(l.l_extendedprice) AS total_sales FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE l.l_shipdate >= CURRENT_DATE - INTERVAL 30 DAY GROUP BY p.p_name;;
-- Q020: Total spending per customer.
SELECT c.c_name, SUM(o.o_totalprice) AS spending FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey GROUP BY c.c_name;;
-- Q021: Total lineitems and avg discount for fulfilled orders by high-balance customers.
SELECT o.o_orderkey, COUNT(l.l_linenumber) AS total_lineitems, ROUND(AVG(l.l_discount), 3) AS avg_discount FROM orders o JOIN lineitem l ON o.o_orderkey = l.l_orderkey JOIN customer c ON o.o_custkey = c.c_custkey WHERE o.o_orderstatus = 'F' AND c.c_acctbal > 1000 GROUP BY o.o_orderkey;;
-- Q022: Number of orders per automobile segment customer since 1995.
SELECT c.c_name, COUNT(o.o_orderkey) AS number_of_orders FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey WHERE c.c_mktsegment = 'AUTOMOBILE' AND o.o_orderdate >= DATE '1995-01-01' GROUP BY c.c_name;;
-- Q023: Total supply cost for suppliers with negative balance and high quantity stock.
SELECT s.s_name, SUM(ps.ps_supplycost) AS total_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE s.s_acctbal < 0 AND ps.ps_availqty > 300 GROUP BY s.s_name;;
-- Q024: Sales for parts with recent shipments and medium discounts.
SELECT p.p_name, SUM(l.l_extendedprice) AS sales FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE l.l_shipdate >= CURRENT_DATE - INTERVAL 30 DAY AND l.l_discount BETWEEN 0.03 AND 0.07 GROUP BY p.p_name;;
-- Q025: Nation revenue with recent shipping and low tax.
SELECT n.n_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue FROM nation n JOIN supplier s ON n.n_nationkey = s.s_nationkey JOIN lineitem l ON s.s_suppkey = l.l_suppkey WHERE l.l_shipdate >= DATE '1994-01-01' AND l.l_tax < 0.05 GROUP BY n.n_name;;
-- Q026: Total lineitems and avg discount for urgent fulfilled orders.
SELECT o.o_orderkey, COUNT(l.l_linenumber) AS total_lineitems, ROUND(AVG(l.l_discount), 3) AS avg_discount FROM orders o JOIN lineitem l ON o.o_orderkey = l.l_orderkey WHERE o.o_orderpriority = '1-URGENT' AND o.o_orderstatus = 'F' GROUP BY o.o_orderkey;;
-- Q027: Number of open orders per customer from nation 5.
SELECT c.c_name, COUNT(o.o_orderkey) AS number_of_orders FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey WHERE c.c_nationkey = 5 AND o.o_orderstatus = 'O' GROUP BY c.c_name;;
-- Q028: Total parts supplied by suppliers with high balance and low quantity.
SELECT s.s_name, COUNT(ps.ps_partkey) AS part_count FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE s.s_acctbal > 1000 AND ps.ps_availqty < 200 GROUP BY s.s_name;;
-- Q029: Total supply cost from suppliers with economic-related comments.
SELECT s.s_name, ROUND(SUM(ps.ps_supplycost), 2) AS total_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE ps.ps_comment LIKE '%economy%' GROUP BY s.s_name;;
-- Q030: Sales for parts shipped by AIR with small quantities.
SELECT p.p_name, SUM(l.l_extendedprice) AS sales FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE l.l_shipmode = 'AIR' AND l.l_quantity < 10 GROUP BY p.p_name;;
-- Q031: Nation revenue within a specific region.
SELECT n.n_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue FROM nation n JOIN supplier s ON n.n_nationkey = s.s_nationkey JOIN lineitem l ON s.s_suppkey = l.l_suppkey WHERE n.n_regionkey = 1 GROUP BY n.n_name;;
-- Q032: Fulfilled orders in 1993 per region.
SELECT r.r_name, COUNT(*) AS orders_1993 FROM region r JOIN nation n ON r.r_regionkey = n.n_regionkey JOIN customer c ON n.n_nationkey = c.c_nationkey JOIN orders o ON c.c_custkey = o.o_custkey WHERE EXTRACT(YEAR FROM o.o_orderdate) = 1993 AND o.o_orderstatus = 'F' GROUP BY r.r_name;;
-- Q033: Customer spending for furniture segment and specific clerks.
SELECT c.c_name, SUM(o.o_totalprice) AS total_spent FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey WHERE o.o_clerk LIKE 'Clerk#000%' AND c.c_mktsegment = 'FURNITURE' GROUP BY c.c_name;;
-- Q034: Average cost from suppliers with promotional comments.
SELECT s.s_name, ROUND(AVG(ps.ps_supplycost), 2) AS avg_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE s.s_comment LIKE '%promotional%' GROUP BY s.s_name;;
-- Q035: Count of small shipments sent via MAIL per part.
SELECT p.p_name, COUNT(l.l_orderkey) AS small_shipments FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE l.l_quantity < 5 AND l.l_shipmode = 'MAIL' GROUP BY p.p_name;;
-- Q036: Total lineitems and average discount for low-priority orders with large quantities.
SELECT o.o_orderkey, COUNT(l.l_linenumber) AS total_lineitems, ROUND(AVG(l.l_discount), 2) AS avg_discount FROM orders o JOIN lineitem l ON o.o_orderkey = l.l_orderkey WHERE o.o_shippriority = 0 AND l.l_quantity > 25 GROUP BY o.o_orderkey;;
-- Q037: High priority orders from customers living on 'Street'.
SELECT c.c_name, COUNT(o.o_orderkey) AS number_of_orders FROM customer c JOIN orders o ON c.c_custkey = o.o_custkey WHERE c.c_address LIKE '%Street%' AND o.o_orderpriority = '2-HIGH' GROUP BY c.c_name;;
-- Q038: Total supply cost from suppliers in nation 3 with affordable stock.
SELECT s.s_name, SUM(ps.ps_supplycost) AS total_supply_cost FROM supplier s JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey WHERE s.s_nationkey = 3 AND ps.ps_supplycost < 500 GROUP BY s.s_name;;
-- Q039: Total truck-shipped sales for standard type parts.
SELECT p.p_name, SUM(l.l_extendedprice) AS total_sales FROM part p JOIN lineitem l ON p.p_partkey = l.l_partkey WHERE p.p_type LIKE 'STANDARD%' AND l.l_shipmode = 'TRUCK' GROUP BY p.p_name;;
-- Q040: Revenue from nations with high balance suppliers and low tax items.
SELECT n.n_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue FROM nation n JOIN supplier s ON n.n_nationkey = s.s_nationkey JOIN lineitem l ON s.s_suppkey = l.l_suppkey WHERE s.s_acctbal > 500 AND l.l_tax < 0.03 GROUP BY n.n_name;;
-- Q041: Top 10 customers by total spending in EUROPE
SELECT c.c_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
JOIN supplier s ON l.l_suppkey = s.s_suppkey
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'EUROPE'
GROUP BY c.c_name
ORDER BY total_spent DESC
LIMIT 10;;
-- Q042: Top 10 suppliers by average discount given
SELECT s.s_name, AVG(l.l_discount) AS avg_discount
FROM supplier s
JOIN lineitem l ON s.s_suppkey = l.l_suppkey
GROUP BY s.s_name
ORDER BY avg_discount DESC
LIMIT 10;;
-- Q043: Revenue per nation from parts sold
SELECT n.n_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM nation n
JOIN supplier s ON n.n_nationkey = s.s_nationkey
JOIN lineitem l ON s.s_suppkey = l.l_suppkey
GROUP BY n.n_name
ORDER BY revenue DESC;;
-- Q044: Total number of orders per region in 1992
SELECT r.r_name, COUNT(DISTINCT o.o_orderkey) AS num_orders
FROM region r
JOIN nation n ON r.r_regionkey = n.n_regionkey
JOIN customer c ON n.n_nationkey = c.c_nationkey
JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_orderdate BETWEEN DATE '1992-01-01' AND DATE '1992-12-31'
GROUP BY r.r_name;;
-- Q045: Top 10 parts by sales in the last 30 days
SELECT p.p_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_sales
FROM part p
JOIN lineitem l ON p.p_partkey = l.l_partkey
WHERE l.l_shipdate >= DATE '1998-08-01'
GROUP BY p.p_name
ORDER BY total_sales DESC
LIMIT 10;;
-- Q046: Customers with more than 10 orders
SELECT c.c_name, COUNT(o.o_orderkey) AS num_orders
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_name
HAVING COUNT(o.o_orderkey) > 10
ORDER BY num_orders DESC;;
-- Q047: Suppliers with highest supply cost
SELECT s.s_name, SUM(ps.ps_supplycost * ps.ps_availqty) AS total_cost
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_name
ORDER BY total_cost DESC
LIMIT 10;;
-- Q048: Total lineitems per order
SELECT o.o_orderkey, COUNT(l.l_linenumber) AS lineitem_count
FROM orders o
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY o.o_orderkey;;
-- Q049: Average discount per order
SELECT o.o_orderkey, AVG(l.l_discount) AS avg_discount
FROM orders o
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY o.o_orderkey;;
-- Q050: Total parts supplied per supplier
SELECT s.s_name, SUM(ps.ps_availqty) AS total_parts
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_name
ORDER BY total_parts DESC;;
-- Q051: Total quantity of parts shipped by supplier in ASIA
SELECT s.s_name, SUM(l.l_quantity) AS total_qty
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
JOIN lineitem l ON s.s_suppkey = l.l_suppkey
WHERE r.r_name = 'ASIA'
GROUP BY s.s_name
ORDER BY total_qty DESC;;
-- Q052: Revenue by region in 1993
SELECT r.r_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM region r
JOIN nation n ON r.r_regionkey = n.n_regionkey
JOIN customer c ON n.n_nationkey = c.c_nationkey
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
WHERE o.o_orderdate BETWEEN DATE '1993-01-01' AND DATE '1993-12-31'
GROUP BY r.r_name
ORDER BY revenue DESC;;
-- Q053: Top 5 parts by number of suppliers
SELECT p.p_name, COUNT(DISTINCT ps.ps_suppkey) AS num_suppliers
FROM part p
JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
GROUP BY p.p_name
ORDER BY num_suppliers DESC
LIMIT 5;;
-- Q054: Customers with the highest number of lineitems
SELECT c.c_name, COUNT(l.l_linenumber) AS lineitems
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY c.c_name
ORDER BY lineitems DESC
LIMIT 10;;
-- Q055: Revenue by supplier from EUROPE
SELECT s.s_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
JOIN lineitem l ON s.s_suppkey = l.l_suppkey
WHERE r.r_name = 'EUROPE'
GROUP BY s.s_name
ORDER BY revenue DESC
LIMIT 10;;
-- Q056: Orders per customer segment in 1994
SELECT c.c_mktsegment, COUNT(o.o_orderkey) AS total_orders
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_orderdate BETWEEN DATE '1994-01-01' AND DATE '1994-12-31'
GROUP BY c.c_mktsegment
ORDER BY total_orders DESC;;
-- Q057: Top 10 revenue-generating orders
SELECT o.o_orderkey, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM orders o
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY o.o_orderkey
ORDER BY revenue DESC
LIMIT 10;;
-- Q058: Total part cost per region
SELECT r.r_name, SUM(ps.ps_supplycost * ps.ps_availqty) AS total_cost
FROM region r
JOIN nation n ON r.r_regionkey = n.n_regionkey
JOIN supplier s ON n.n_nationkey = s.s_nationkey
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY r.r_name
ORDER BY total_cost DESC;;
-- Q059: Top 10 parts by revenue
SELECT p.p_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM part p
JOIN lineitem l ON p.p_partkey = l.l_partkey
GROUP BY p.p_name
ORDER BY revenue DESC
LIMIT 10;;
-- Q060: Orders by region for year 1994
SELECT r.r_name, COUNT(o.o_orderkey) AS order_count
FROM region r
JOIN nation n ON r.r_regionkey = n.n_regionkey
JOIN customer c ON n.n_nationkey = c.c_nationkey
JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_orderdate BETWEEN DATE '1994-01-01' AND DATE '1994-12-31'
GROUP BY r.r_name;;
-- Q061: Customers who spent more than average total spending
SELECT c.c_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY c.c_name
HAVING SUM(l.l_extendedprice * (1 - l.l_discount)) >
       (SELECT AVG(total) FROM (
            SELECT SUM(l2.l_extendedprice * (1 - l2.l_discount)) AS total
            FROM customer c2
            JOIN orders o2 ON c2.c_custkey = o2.o_custkey
            JOIN lineitem l2 ON o2.o_orderkey = l2.l_orderkey
            GROUP BY c2.c_name
       ));;
-- Q062: Suppliers who supplied more parts than the average
SELECT s.s_name, SUM(ps.ps_availqty) AS total_parts
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_name
HAVING SUM(ps.ps_availqty) > (
    SELECT AVG(total_qty) FROM (
        SELECT SUM(ps2.ps_availqty) AS total_qty
        FROM supplier s2
        JOIN partsupp ps2 ON s2.s_suppkey = ps2.ps_suppkey
        GROUP BY s2.s_name
    )
);;
-- Q063: Orders with more lineitems than average
SELECT o.o_orderkey, COUNT(l.l_linenumber) AS num_lineitems
FROM orders o
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY o.o_orderkey
HAVING COUNT(l.l_linenumber) > (
    SELECT AVG(num) FROM (
        SELECT COUNT(l2.l_linenumber) AS num
        FROM orders o2
        JOIN lineitem l2 ON o2.o_orderkey = l2.l_orderkey
        GROUP BY o2.o_orderkey
    )
);;
-- Q064: Customers who placed more orders than average
SELECT c.c_name, COUNT(o.o_orderkey) AS order_count
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_name
HAVING COUNT(o.o_orderkey) > (
    SELECT AVG(cnt) FROM (
        SELECT COUNT(o2.o_orderkey) AS cnt
        FROM customer c2
        JOIN orders o2 ON c2.c_custkey = o2.o_custkey
        GROUP BY c2.c_name
    )
);;
-- Q065: Suppliers with supply cost above average
SELECT s.s_name, SUM(ps.ps_supplycost * ps.ps_availqty) AS total_cost
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_name
HAVING SUM(ps.ps_supplycost * ps.ps_availqty) > (
    SELECT AVG(cost) FROM (
        SELECT SUM(ps2.ps_supplycost * ps2.ps_availqty) AS cost
        FROM supplier s2
        JOIN partsupp ps2 ON s2.s_suppkey = ps2.ps_suppkey
        GROUP BY s2.s_name
    )
);;
-- Q066: Parts with higher than average recent sales
SELECT p.p_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS recent_sales
FROM part p
JOIN lineitem l ON p.p_partkey = l.l_partkey
WHERE l.l_shipdate >= DATE '1998-08-01'
GROUP BY p.p_name
HAVING SUM(l.l_extendedprice * (1 - l.l_discount)) > (
    SELECT AVG(total) FROM (
        SELECT SUM(l2.l_extendedprice * (1 - l2.l_discount)) AS total
        FROM part p2
        JOIN lineitem l2 ON p2.p_partkey = l2.l_partkey
        WHERE l2.l_shipdate >= DATE '1998-08-01'
        GROUP BY p2.p_name
    )
);;
-- Q067: Regions with more orders than average in 1992
SELECT r.r_name, COUNT(DISTINCT o.o_orderkey) AS num_orders
FROM region r
JOIN nation n ON r.r_regionkey = n.n_regionkey
JOIN customer c ON n.n_nationkey = c.c_nationkey
JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_orderdate BETWEEN DATE '1992-01-01' AND DATE '1992-12-31'
GROUP BY r.r_name
HAVING COUNT(DISTINCT o.o_orderkey) > (
    SELECT AVG(order_count) FROM (
        SELECT COUNT(DISTINCT o2.o_orderkey) AS order_count
        FROM region r2
        JOIN nation n2 ON r2.r_regionkey = n2.n_regionkey
        JOIN customer c2 ON n2.n_nationkey = c2.c_nationkey
        JOIN orders o2 ON c2.c_custkey = o2.o_custkey
        WHERE o2.o_orderdate BETWEEN DATE '1992-01-01' AND DATE '1992-12-31'
        GROUP BY r2.r_name
    )
);;
-- Q068: Nations with above average revenue
SELECT n.n_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM nation n
JOIN supplier s ON n.n_nationkey = s.s_nationkey
JOIN lineitem l ON s.s_suppkey = l.l_suppkey
GROUP BY n.n_name
HAVING SUM(l.l_extendedprice * (1 - l.l_discount)) > (
    SELECT AVG(rev) FROM (
        SELECT SUM(l2.l_extendedprice * (1 - l2.l_discount)) AS rev
        FROM nation n2
        JOIN supplier s2 ON n2.n_nationkey = s2.s_nationkey
        JOIN lineitem l2 ON s2.s_suppkey = l2.l_suppkey
        GROUP BY n2.n_name
    )
);;
-- Q069: Orders with average discount above global average
SELECT o.o_orderkey, AVG(l.l_discount) AS avg_discount
FROM orders o
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY o.o_orderkey
HAVING AVG(l.l_discount) > (
    SELECT AVG(l2.l_discount)
    FROM lineitem l2
);;
-- Q070: Customers who spent more than any supplier supplied
SELECT c.c_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY c.c_name
HAVING SUM(l.l_extendedprice * (1 - l.l_discount)) > ALL (
    SELECT SUM(ps.ps_availqty * ps.ps_supplycost)
    FROM supplier s
    JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
    GROUP BY s.s_name
);;
-- Q071: Customers with total spent higher than the highest supplier cost
SELECT c.c_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY c.c_name
HAVING SUM(l.l_extendedprice * (1 - l.l_discount)) > (
    SELECT MAX(total_cost)
    FROM (
        SELECT SUM(ps.ps_availqty * ps.ps_supplycost) AS total_cost
        FROM supplier s
        JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
        GROUP BY s.s_name
    ) supplier_costs
);;
-- Q072: Suppliers supplying parts for all regions
SELECT s.s_name
FROM supplier s
WHERE NOT EXISTS (
    SELECT r.r_regionkey
    FROM region r
    WHERE NOT EXISTS (
        SELECT 1
        FROM nation n
        JOIN part p ON 1=1
        JOIN partsupp ps ON ps.ps_partkey = p.p_partkey AND ps.ps_suppkey = s.s_suppkey
        WHERE n.n_regionkey = r.r_regionkey AND s.s_nationkey = n.n_nationkey
    )
);;
-- Q073: Parts whose total sales are above average in last 30 days
SELECT p.p_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS recent_sales
FROM part p
JOIN lineitem l ON p.p_partkey = l.l_partkey
WHERE l.l_shipdate >= DATE '1998-08-01'
GROUP BY p.p_name
HAVING SUM(l.l_extendedprice * (1 - l.l_discount)) > (
    SELECT AVG(sales)
    FROM (
        SELECT SUM(l2.l_extendedprice * (1 - l2.l_discount)) AS sales
        FROM part p2
        JOIN lineitem l2 ON p2.p_partkey = l2.l_partkey
        WHERE l2.l_shipdate >= DATE '1998-08-01'
        GROUP BY p2.p_name
    )
);;
-- Q074: Nations with revenue greater than at least one other nation
SELECT n.n_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM nation n
JOIN supplier s ON n.n_nationkey = s.s_nationkey
JOIN lineitem l ON s.s_suppkey = l.l_suppkey
GROUP BY n.n_name
HAVING SUM(l.l_extendedprice * (1 - l.l_discount)) > (
    SELECT MIN(revenue)
    FROM (
        SELECT SUM(l2.l_extendedprice * (1 - l2.l_discount)) AS revenue
        FROM nation n2
        JOIN supplier s2 ON n2.n_nationkey = s2.s_nationkey
        JOIN lineitem l2 ON s2.s_suppkey = l2.l_suppkey
        GROUP BY n2.n_name
    )
);;
-- Q075: Orders with more lineitems than any other
SELECT o.o_orderkey, COUNT(l.l_linenumber) AS lineitem_count
FROM orders o
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY o.o_orderkey
HAVING COUNT(l.l_linenumber) > ALL (
    SELECT COUNT(l2.l_linenumber)
    FROM orders o2
    JOIN lineitem l2 ON o2.o_orderkey = l2.l_orderkey
    GROUP BY o2.o_orderkey
);;
-- Q076: Suppliers whose average supply cost is above global average
SELECT s.s_name, AVG(ps.ps_supplycost) AS avg_cost
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_name
HAVING AVG(ps.ps_supplycost) > (
    SELECT AVG(ps2.ps_supplycost)
    FROM partsupp ps2
);;
-- Q077: Suppliers whose total cost is higher than any customer spent
SELECT s.s_name, SUM(ps.ps_supplycost * ps.ps_availqty) AS total_cost
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_name
HAVING SUM(ps.ps_supplycost * ps.ps_availqty) > ALL (
    SELECT SUM(l.l_extendedprice * (1 - l.l_discount))
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    GROUP BY c.c_name
);;
-- Q078: Orders with average discount lower than any other
SELECT o.o_orderkey, AVG(l.l_discount) AS avg_discount
FROM orders o
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY o.o_orderkey
HAVING AVG(l.l_discount) < ALL (
    SELECT AVG(l2.l_discount)
    FROM orders o2
    JOIN lineitem l2 ON o2.o_orderkey = l2.l_orderkey
    GROUP BY o2.o_orderkey
);;
-- Q079: Customers whose total spending is more than the total spending of all customers in ASIA
SELECT c.c_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
GROUP BY c.c_custkey, c.c_name
HAVING SUM(l.l_extendedprice * (1 - l.l_discount)) > (
    SELECT SUM(l2.l_extendedprice * (1 - l2.l_discount))
    FROM customer c2
    JOIN orders o2 ON c2.c_custkey = o2.o_custkey
    JOIN lineitem l2 ON o2.o_orderkey = l2.l_orderkey
    JOIN nation n ON c2.c_nationkey = n.n_nationkey
    JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE r.r_name = 'ASIA'
);;
-- Q080: Suppliers who supply more parts than any customer has ordered
SELECT s.s_name, SUM(ps.ps_availqty) AS total_supplied
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_suppkey, s.s_name
HAVING SUM(ps.ps_availqty) > ALL (
    SELECT COUNT(l.l_partkey)
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    GROUP BY c.c_custkey
);;
-- Q081: Rank customers by total spending using a window function
WITH customer_spending AS (
    SELECT c.c_custkey, c.c_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    GROUP BY c.c_custkey, c.c_name
)
SELECT *, RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_spending
LIMIT 10;;
-- Q082: Find top supplier per region by supply cost
WITH regional_supply AS (
    SELECT r.r_name, s.s_name, SUM(ps.ps_availqty * ps.ps_supplycost) AS total_cost
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN supplier s ON n.n_nationkey = s.s_nationkey
    JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
    GROUP BY r.r_name, s.s_name
)
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY r_name ORDER BY total_cost DESC) AS rank
    FROM regional_supply
)
WHERE rank = 1;;
-- Q083: Calculate running total of part sales
WITH part_sales AS (
    SELECT p.p_partkey, p.p_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS sales
    FROM part p
    JOIN lineitem l ON p.p_partkey = l.l_partkey
    GROUP BY p.p_partkey, p.p_name
)
SELECT p_name, sales,
       SUM(sales) OVER (ORDER BY sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM part_sales
ORDER BY sales DESC
LIMIT 10;;
-- Q084: Find average discount per customer order using a CTE
WITH customer_order_discounts AS (
    SELECT c.c_name, o.o_orderkey, AVG(l.l_discount) AS avg_discount
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    GROUP BY c.c_name, o.o_orderkey
)
SELECT * FROM customer_order_discounts
WHERE avg_discount > 0.05
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
WITH spending AS (
    SELECT r.r_name, c.c_custkey,
           SUM(l.l_extendedprice * (1 - l.l_discount)) AS cust_spent
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN customer c ON n.n_nationkey = c.c_nationkey
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    GROUP BY r.r_name, c.c_custkey
)
SELECT r_name,
       SUM(cust_spent) AS total_region_spent,
       AVG(cust_spent) AS avg_region_spent
FROM spending
GROUP BY r_name;;
-- Q087: Rank suppliers by average supply cost using dense_rank
SELECT s.s_name, AVG(ps.ps_supplycost) AS avg_cost,
       DENSE_RANK() OVER (ORDER BY AVG(ps.ps_supplycost) DESC) AS cost_rank
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_name;;
-- Q088: Find top 3 customers by orders per market segment
WITH customer_orders AS (
    SELECT c.c_mktsegment, c.c_name, COUNT(o.o_orderkey) AS order_count
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_mktsegment, c.c_name
)
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY c_mktsegment ORDER BY order_count DESC) AS rank
    FROM customer_orders
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
    SELECT r.r_name, s.s_name,
           SUM(ps.ps_availqty * ps.ps_supplycost) AS total_cost
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN supplier s ON n.n_nationkey = s.s_nationkey
    JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
    GROUP BY r.r_name, s.s_name
)
SELECT *,
       AVG(total_cost) OVER (PARTITION BY r_name) AS regional_avg
FROM supplier_costs;;
-- Q091: Identify the region with the most orders over all time
WITH regional_orders AS (
    SELECT r.r_name, COUNT(o.o_orderkey) AS total_orders
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN customer c ON n.n_nationkey = c.c_nationkey
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY r.r_name
)
SELECT *
FROM (
    SELECT *, RANK() OVER (ORDER BY total_orders DESC) AS rank
    FROM regional_orders
)
WHERE rank = 1;;
-- Q092: Calculate moving average of part sales
WITH part_sales AS (
    SELECT p.p_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS sales
    FROM part p
    JOIN lineitem l ON p.p_partkey = l.l_partkey
    GROUP BY p.p_name
)
SELECT p_name, sales,
       AVG(sales) OVER (ORDER BY sales ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM part_sales
ORDER BY sales DESC;;
-- Q093: Detect customers with spending significantly above their segment average
WITH customer_spending AS (
    SELECT c.c_custkey, c.c_name, c.c_mktsegment,
           SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),
segment_avg AS (
    SELECT c_mktsegment, AVG(total_spent) AS avg_segment_spent
    FROM customer_spending
    GROUP BY c_mktsegment
)
SELECT cs.c_name, cs.c_mktsegment, cs.total_spent, sa.avg_segment_spent
FROM customer_spending cs
JOIN segment_avg sa ON cs.c_mktsegment = sa.c_mktsegment
WHERE cs.total_spent > 1.5 * sa.avg_segment_spent;;
-- Q094: Top 3 parts per brand by revenue
WITH part_revenue AS (
    SELECT p.p_brand, p.p_name,
           SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
    FROM part p
    JOIN lineitem l ON p.p_partkey = l.l_partkey
    GROUP BY p.p_brand, p.p_name
)
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY p_brand ORDER BY revenue DESC) AS rank
    FROM part_revenue
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
WITH yearly_orders AS (
    SELECT r.r_name, DATE_PART('year', o.o_orderdate) AS year, COUNT(*) AS order_count
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN customer c ON n.n_nationkey = c.c_nationkey
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY r.r_name, year
)
SELECT *, SUM(order_count) OVER (PARTITION BY r_name ORDER BY year) AS cumulative_orders
FROM yearly_orders
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
    SELECT r.r_name, s.s_name, SUM(ps.ps_availqty * ps.ps_supplycost) AS total_cost
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN supplier s ON n.n_nationkey = s.s_nationkey
    JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
    GROUP BY r.r_name, s.s_name
)
SELECT *, total_cost * 1.0 / SUM(total_cost) OVER (PARTITION BY r_name) AS cost_share
FROM supplier_costs;;
-- Q099: Find customers whose rank in orders differs from rank in spending
WITH order_ranks AS (
    SELECT c.c_name, COUNT(o.o_orderkey) AS num_orders,
           RANK() OVER (ORDER BY COUNT(o.o_orderkey) DESC) AS order_rank
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_name
),
spend_ranks AS (
    SELECT c.c_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent,
           RANK() OVER (ORDER BY SUM(l.l_extendedprice * (1 - l.l_discount)) DESC) AS spend_rank
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    GROUP BY c.c_name
)
SELECT o.c_name, o.order_rank, s.spend_rank
FROM order_ranks o
JOIN spend_ranks s ON o.c_name = s.c_name
WHERE ABS(o.order_rank - s.spend_rank) > 5;;
-- Q100: Identify top customer per region by total spent
WITH customer_spent AS (
    SELECT r.r_name, c.c_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS spent
    FROM region r
    JOIN nation n ON r.r_regionkey = n.n_regionkey
    JOIN customer c ON n.n_nationkey = c.c_nationkey
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    GROUP BY r.r_name, c.c_name
)
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY r_name ORDER BY spent DESC) AS rank
    FROM customer_spent
)
WHERE rank = 1;;
