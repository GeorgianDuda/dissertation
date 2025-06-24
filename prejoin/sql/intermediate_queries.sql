-- Q001: Total Revenue by Region
SELECT r.r_name, SUM(lo.l_extendedprice * (1 - lo.l_discount)) AS revenue
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
GROUP BY r.r_name;

-- Q002: Total Quantity by Part Brand
SELECT p_brand, SUM(lo.l_quantity) AS total_qty
FROM lineitem_orders lo
JOIN part p ON lo.l_partkey = p.p_partkey
GROUP BY p_brand;

-- Q003: Average Discount by Supplier Nation
SELECT n.n_name AS nation, AVG(l.l_discount) AS avg_discount
FROM partsupp_supplier_part psp
JOIN nation n ON psp.s_nationkey = n.n_nationkey
JOIN lineitem l ON l.l_partkey = psp.ps_partkey AND l.l_suppkey = psp.ps_suppkey
GROUP BY n.n_name;

-- Q004: Total extended price per part type
SELECT p_type, SUM(lo.l_extendedprice) AS total_price
FROM lineitem_orders lo
JOIN part p ON lo.l_partkey = p.p_partkey
GROUP BY p_type;

-- Q005: Count of orders by order priority
SELECT o_orderpriority, COUNT(DISTINCT lo.l_orderkey) AS num_orders
FROM lineitem_orders lo
GROUP BY o_orderpriority;

-- Q006: Average quantity per part container
SELECT p_container, AVG(lo.l_quantity) AS avg_qty
FROM lineitem_orders lo
JOIN part p ON lo.l_partkey = p.p_partkey
GROUP BY p_container;

-- Q007: Revenue by supplier name
SELECT s.s_name, SUM(lo.l_extendedprice * (1 - lo.l_discount)) AS revenue
FROM lineitem_orders lo
JOIN supplier s ON lo.l_suppkey = s.s_suppkey
GROUP BY s.s_name;

-- Q008: Average account balance by market segment
SELECT c.c_mktsegment, AVG(c.c_acctbal) AS avg_acctbal
FROM customer c
GROUP BY c.c_mktsegment;

-- Q009: Total supply cost by part manufacturer
SELECT psp.p_mfgr, SUM(psp.ps_supplycost * psp.ps_availqty) AS total_cost
FROM partsupp_supplier_part psp
GROUP BY psp.p_mfgr;

-- Q010: Order count by customer region
SELECT r.r_name, COUNT(DISTINCT lo.l_orderkey) AS order_count
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
GROUP BY r.r_name;

-- Q011: Total extended price grouped by shipping mode
SELECT l_shipmode, SUM(l_extendedprice) AS total_price
FROM lineitem_orders
GROUP BY l_shipmode;

-- Q012: Count of lineitems grouped by return flag
SELECT l_returnflag, COUNT(*) AS item_count
FROM lineitem_orders
GROUP BY l_returnflag;

-- Q013: Average quantity of items grouped by part size
SELECT p_size, AVG(lo.l_quantity) AS avg_qty
FROM lineitem_orders lo
JOIN part p ON lo.l_partkey = p.p_partkey
GROUP BY p_size;

-- Q014: Revenue by customer market segment
SELECT c.c_mktsegment, SUM(lo.l_extendedprice * (1 - lo.l_discount)) AS revenue
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
GROUP BY c.c_mktsegment;

-- Q015: Maximum discount grouped by part brand
SELECT p_brand, MAX(lo.l_discount) AS max_discount
FROM lineitem_orders lo
JOIN part p ON lo.l_partkey = p.p_partkey
GROUP BY p_brand;

-- Q016: Number of unique suppliers in each region
SELECT r.r_name, COUNT(DISTINCT psp.ps_suppkey) AS supplier_count
FROM partsupp_supplier_part psp
JOIN nation n ON psp.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
GROUP BY r.r_name;

-- Q017: Minimum supply cost offered by each supplier
SELECT s_name, MIN(ps_supplycost) AS min_cost
FROM partsupp_supplier_part
GROUP BY s_name;

-- Q018: Total shipped quantity grouped by ship year
SELECT EXTRACT(YEAR FROM l_shipdate) AS ship_year, SUM(l_quantity) AS total_qty
FROM lineitem_orders
GROUP BY ship_year;

-- Q019: Total inventory value (supply cost * quantity) grouped by container
SELECT p_container, SUM(ps_availqty * ps_supplycost) AS total_value
FROM partsupp_supplier_part
GROUP BY p_container;

-- Q020: Average order total value grouped by region
SELECT r.r_name, AVG(lo.o_totalprice) AS avg_order_total
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
GROUP BY r.r_name;

-- Q021: Orders placed in 1994 by customers in the 'BUILDING' segment with discount between 5%-7% and quantity < 24
SELECT 
    lo.l_orderkey, 
    lo.l_extendedprice, 
    lo.l_discount, 
    lo.o_orderdate, 
    c.c_mktsegment
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
WHERE lo.l_discount BETWEEN 0.05 AND 0.07
  AND lo.l_quantity < 24
  AND lo.o_orderdate >= DATE '1994-01-01'
  AND lo.o_orderdate < DATE '1995-01-01'
  AND c.c_mktsegment = 'BUILDING';

-- Q022: High-value orders shipped by 'RAIL' in 1995 with discount < 3% and total price above 200,000
SELECT 
    lo.l_orderkey, 
    lo.l_extendedprice, 
    lo.l_discount, 
    lo.l_shipmode, 
    lo.o_orderdate, 
    lo.o_totalprice
FROM lineitem_orders lo
WHERE lo.l_shipmode = 'RAIL'
  AND lo.o_totalprice > 200000
  AND lo.l_discount < 0.03
  AND lo.o_orderdate BETWEEN DATE '1995-01-01' AND DATE '1995-12-31';

-- Q023: Suppliers from 'EUROPE' with account balance > 5000 and phone starting with '33-'
SELECT 
    ps.s_name, 
    ps.s_acctbal, 
    ps.s_phone, 
    r.r_name
FROM partsupp_supplier_part ps
JOIN nation n ON ps.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'EUROPE'
  AND ps.s_acctbal > 5000
  AND ps.s_phone LIKE '33-%';

-- Q024: Parts of type 'ECONOMY ANODIZED STEEL' and supply cost < 300
SELECT 
    ps.ps_partkey, 
    ps.p_type, 
    ps.ps_supplycost
FROM partsupp_supplier_part ps
WHERE ps.p_type = 'ECONOMY ANODIZED STEEL'
  AND ps.ps_supplycost < 300;

-- Q025: Orders placed by clerks starting with 'Clerk#000000' with total price > 100000
SELECT 
    lo.l_orderkey, 
    lo.o_clerk, 
    lo.o_totalprice
FROM lineitem_orders lo
WHERE lo.o_clerk LIKE 'Clerk#000000%'
  AND lo.o_totalprice > 100000;

-- Q026: Lineitems shipped before 1996-12-01, commit date after ship date, and quantity > 30
SELECT 
    lo.l_orderkey, 
    lo.l_shipdate, 
    lo.l_commitdate, 
    lo.l_quantity
FROM lineitem_orders lo
WHERE lo.l_shipdate < DATE '1996-12-01'
  AND lo.l_commitdate > lo.l_shipdate
  AND lo.l_quantity > 30;

-- Q027: Customers with comment containing 'a' and phone starting in '33'
SELECT 
    c.c_custkey, 
    c.c_name, 
    c.c_phone, 
    c.c_comment
FROM customer c
WHERE c.c_comment LIKE '%a%'
  AND c.c_phone LIKE '%33';

-- Q028: Parts not containing 'COPPER' in name and size in (10, 20, 30)
SELECT 
    ps.ps_partkey, 
    ps.p_name, 
    ps.p_size
FROM partsupp_supplier_part ps
WHERE ps.p_name NOT LIKE '%COPPER%'
  AND ps.p_size IN (10, 20, 30);

-- Q029: Lineitems with extended price > 50000 and discount < 0.02
SELECT 
    lo.l_orderkey, 
    lo.l_extendedprice, 
    lo.l_discount
FROM lineitem_orders lo
WHERE lo.l_extendedprice > 50000
  AND lo.l_discount < 0.02;

-- Q030: Customers from 'UNITED STATES' with account balance > 1000 and not in 'AUTOMOBILE' segment
SELECT 
    c.c_name, 
    c.c_acctbal, 
    n.n_name, 
    c.c_mktsegment
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE n.n_name = 'UNITED STATES'
  AND c.c_acctbal > 1000
  AND c.c_mktsegment != 'AUTOMOBILE';

-- Q031: Orders placed in March 1995 with '2-HIGH' priority and quantity between 10 and 30
SELECT 
    lo.l_orderkey, 
    lo.o_orderpriority, 
    lo.o_orderdate, 
    lo.l_quantity
FROM lineitem_orders lo
WHERE lo.o_orderpriority = '2-HIGH'
  AND lo.o_orderdate BETWEEN DATE '1995-03-01' AND DATE '1995-03-31'
  AND lo.l_quantity BETWEEN 10 AND 30;

-- Q032: Parts with retail price over 1500 and type like '%TIN%' and size = 15
SELECT 
    ps.ps_partkey, 
    ps.p_type, 
    ps.p_retailprice, 
    ps.p_size
FROM partsupp_supplier_part ps
WHERE ps.p_retailprice > 1500
  AND ps.p_type LIKE '%TIN%'
  AND ps.p_size = 15;

-- Q033: Customers from 'CHINA' with phone starting with '86-' and account balance < 500
SELECT 
    c.c_name, 
    c.c_acctbal, 
    n.n_name, 
    c.c_phone
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE n.n_name = 'CHINA'
  AND c.c_phone LIKE '86-%'
  AND c.c_acctbal < 500;

-- Q034: Suppliers with comment containing 'unusual' and phone NOT starting with '27-'
SELECT 
    ps.ps_suppkey, 
    ps.s_name, 
    ps.s_phone, 
    ps.s_comment
FROM partsupp_supplier_part ps
WHERE ps.s_comment LIKE '%unusual%'
  AND ps.s_phone NOT LIKE '27-%';

-- Q035: Orders with total price between 100000 and 200000 and clerk ending with '123'
SELECT 
    lo.l_orderkey, 
    lo.o_totalprice, 
    lo.o_clerk
FROM lineitem_orders lo
WHERE lo.o_totalprice BETWEEN 100000 AND 200000
  AND lo.o_clerk LIKE '%123';

-- Q036: Lineitems with receipt date after commit date, and ship instructions = 'DELIVER IN PERSON'
SELECT 
    lo.l_orderkey, 
    lo.l_commitdate, 
    lo.l_receiptdate, 
    lo.l_shipinstruct
FROM lineitem_orders lo
WHERE lo.l_receiptdate > lo.l_commitdate
  AND lo.l_shipinstruct = 'DELIVER IN PERSON';

-- Q037: Suppliers with address containing 'Plaza' and account balance below 100
SELECT 
    ps.ps_suppkey, 
    ps.s_name, 
    ps.s_address, 
    ps.s_acctbal
FROM partsupp_supplier_part ps
WHERE ps.s_address LIKE '%Plaza%'
  AND ps.s_acctbal < 100;

-- Q038: Customers in 'ASIA' region with comments containing 'special requests' and account balance > 1500
SELECT 
    c.c_custkey, 
    c.c_name, 
    c.c_comment, 
    c.c_acctbal, 
    r.r_name
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'ASIA'
  AND c.c_comment LIKE '%special requests%'
  AND c.c_acctbal > 1500;

-- Q039: Lineitems with shipmode 'AIR' or 'FOB' and return flag = 'R'
SELECT 
    lo.l_orderkey, 
    lo.l_shipmode, 
    lo.l_returnflag
FROM lineitem_orders lo
WHERE lo.l_shipmode IN ('AIR', 'FOB')
  AND lo.l_returnflag = 'R';

-- Q040: Parts with container = 'SM BOX' and brand like 'Brand#12' and retail price <= 1000
SELECT 
    ps.ps_partkey, 
    ps.p_brand, 
    ps.p_container, 
    ps.p_retailprice
FROM partsupp_supplier_part ps
WHERE ps.p_container = 'SM BOX'
  AND ps.p_brand LIKE 'Brand#12'
  AND ps.p_retailprice <= 1000;

-- Q041: List orders and customer names for orders placed in 1994
SELECT 
    lo.l_orderkey, 
    lo.o_orderdate, 
    c.c_name
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
WHERE lo.o_orderdate BETWEEN DATE '1994-01-01' AND DATE '1994-12-31';

-- Q042: Return suppliers and their part info for parts with size 10
SELECT 
    ps.s_name, 
    ps.p_name, 
    ps.p_size
FROM partsupp_supplier_part ps
WHERE ps.p_size = 10;

-- Q043: Return lineitem prices with customer and region for orders placed by customers in 'AMERICA'
SELECT 
    lo.l_orderkey, 
    lo.l_extendedprice, 
    c.c_name, 
    r.r_name
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'AMERICA';

-- Q044: Retrieve orders, customer names and their nations for customers with acctbal > 1000
SELECT 
    lo.l_orderkey, 
    lo.o_orderdate, 
    c.c_name, 
    n.n_name
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE c.c_acctbal > 1000;

-- Q045: Find lineitem discounts for parts made by manufacturer 'Manufacturer#1' and supplier comment containing 'rare'
SELECT 
    lo.l_orderkey, 
    lo.l_discount, 
    ps.p_mfgr, 
    ps.s_comment
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey AND lo.l_suppkey = ps.ps_suppkey
WHERE ps.p_mfgr = 'Manufacturer#1'
  AND ps.s_comment LIKE '%rare%';

-- Q046: Return orders, customer, and region info for orders with total price above 250000
SELECT 
    lo.l_orderkey, 
    lo.o_totalprice, 
    c.c_name, 
    r.r_name
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE lo.o_totalprice > 250000;

-- Q047: Return parts with brand 'Brand#34' and their suppliers' names and phone numbers
SELECT 
    ps.ps_partkey, 
    ps.p_brand, 
    ps.s_name, 
    ps.s_phone
FROM partsupp_supplier_part ps
WHERE ps.p_brand = 'Brand#34';

-- Q048: Find orders by customers from 'GERMANY' in 1996 with mktsegment 'AUTOMOBILE'
SELECT 
    lo.l_orderkey, 
    lo.o_orderdate, 
    c.c_name, 
    n.n_name
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE n.n_name = 'GERMANY'
  AND c.c_mktsegment = 'AUTOMOBILE'
  AND lo.o_orderdate BETWEEN DATE '1996-01-01' AND DATE '1996-12-31';

-- Q049: Suppliers from 'JAPAN' delivering parts with container 'LG BOX'
SELECT 
    ps.s_name, 
    ps.s_address, 
    ps.p_name, 
    ps.p_container
FROM partsupp_supplier_part ps
WHERE ps.s_nationkey IN (SELECT n_nationkey FROM nation WHERE n_name = 'JAPAN')
  AND ps.p_container = 'LG BOX';

-- Q050: Return orders with lineitems for parts of type 'SMALL PLATED BRASS'
SELECT 
    lo.l_orderkey, 
    lo.o_orderdate, 
    ps.ps_partkey, 
    ps.p_type
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey
WHERE ps.p_type = 'SMALL PLATED BRASS';

-- Q051: Orders from 'EUROPE' region with customer segment 'FURNITURE'
SELECT 
    lo.l_orderkey, 
    lo.o_orderdate, 
    c.c_name, 
    r.r_name
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'EUROPE'
  AND c.c_mktsegment = 'FURNITURE';

-- Q052: Lineitems of orders with part names containing 'green' and suppliers from 'CANADA'
SELECT 
    lo.l_orderkey, 
    ps.p_name, 
    ps.s_name, 
    n.n_name
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey AND lo.l_suppkey = ps.ps_suppkey
JOIN nation n ON ps.s_nationkey = n.n_nationkey
WHERE ps.p_name LIKE '%green%'
  AND n.n_name = 'CANADA';

-- Q053: Orders and customer names where the customer is from 'ARGENTINA' and total price > 150000
SELECT 
    lo.l_orderkey, 
    lo.o_totalprice, 
    c.c_name, 
    n.n_name
FROM lineitem_orders lo
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE n.n_name = 'ARGENTINA'
  AND lo.o_totalprice > 150000;

-- Q054: Parts supplied by 'UNITED KINGDOM' suppliers with supply cost < 200
SELECT 
    ps.ps_partkey, 
    ps.p_name, 
    ps.s_name, 
    ps.ps_supplycost
FROM partsupp_supplier_part ps
JOIN nation n ON ps.s_nationkey = n.n_nationkey
WHERE n.n_name = 'UNITED KINGDOM'
  AND ps.ps_supplycost < 200;

-- Q055: Orders for parts with brand 'Brand#55' shipped using 'FOB'
SELECT 
    lo.l_orderkey, 
    lo.o_orderdate, 
    ps.p_brand, 
    lo.l_shipmode
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey
WHERE ps.p_brand = 'Brand#55'
  AND lo.l_shipmode = 'FOB';

-- Q056: Orders for parts of type 'PROMO POLISHED TIN' by customers in 'ASIA'
SELECT 
    lo.l_orderkey, 
    lo.o_orderdate, 
    ps.p_type, 
    c.c_name, 
    r.r_name
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE ps.p_type = 'PROMO POLISHED TIN'
  AND r.r_name = 'ASIA';

-- Q057: Parts in 'SM CASE' container from suppliers in 'FRANCE'
SELECT 
    ps.ps_partkey, 
    ps.p_name, 
    ps.p_container, 
    ps.s_name, 
    n.n_name
FROM partsupp_supplier_part ps
JOIN nation n ON ps.s_nationkey = n.n_nationkey
WHERE ps.p_container = 'SM CASE'
  AND n.n_name = 'FRANCE';

-- Q058: Lineitems with part brand 'Brand#31' and customer in 'BRAZIL'
SELECT 
    lo.l_orderkey, 
    ps.p_brand, 
    c.c_name, 
    n.n_name
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE ps.p_brand = 'Brand#31'
  AND n.n_name = 'BRAZIL';

-- Q059: Orders in 1993 for parts from suppliers
SELECT 
    o.o_orderkey, 
    o.o_orderdate, 
    p.p_partkey, 
    s.s_name, 
FROM orders o
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
JOIN part p ON l.l_partkey = p.p_partkey
JOIN supplier s ON l.l_suppkey = s.s_suppkey
WHERE o.o_orderdate BETWEEN DATE '1993-01-01' AND DATE '1993-12-31';

-- Q060: Orders placed by customers in 'RUSSIA' with parts of size = 5
SELECT 
    lo.l_orderkey, 
    lo.o_orderdate, 
    ps.p_size, 
    c.c_name, 
    n.n_name
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey
JOIN customer c ON lo.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE ps.p_size = 5
  AND n.n_name = 'RUSSIA';

-- Q061: Orders with totalprice greater than the average totalprice of all orders
SELECT l_orderkey, o_totalprice
FROM lineitem_orders
WHERE o_totalprice > (
    SELECT AVG(o_totalprice) FROM lineitem_orders
);

-- Q062: Parts with supply cost lower than the average cost of all parts
SELECT ps.ps_partkey, ps.ps_supplycost
FROM partsupp_supplier_part ps
WHERE ps.ps_supplycost < (
    SELECT AVG(ps_supplycost) FROM partsupp_supplier_part
);

-- Q063: Customers who have placed at least one order
SELECT c.c_custkey, c.c_name
FROM customer c
WHERE EXISTS (
    SELECT 1 FROM lineitem_orders lo WHERE lo.o_custkey = c.c_custkey
);

-- Q064: Orders that contain at least one lineitem with discount greater than 0.08
SELECT DISTINCT lo.l_orderkey, lo.o_orderdate
FROM lineitem_orders lo
WHERE lo.l_discount > 0.08;

-- Q065: Suppliers who supply at least one part with size 50
SELECT DISTINCT ps.ps_suppkey, ps.s_name
FROM partsupp_supplier_part ps
WHERE ps.p_size = 50;

-- Q066: Customers whose account balance is above the average of customers from 'ASIA'
SELECT c.c_custkey, c.c_name, c.c_acctbal
FROM customer c
WHERE c.c_acctbal > (
    SELECT AVG(c2.c_acctbal)
    FROM customer c2
    JOIN nation n2 ON c2.c_nationkey = n2.n_nationkey
    JOIN region r2 ON n2.n_regionkey = r2.r_regionkey
    WHERE r2.r_name = 'ASIA'
);

-- Q067: Parts with higher retail price than any part of size 15
SELECT ps.ps_partkey, ps.p_name, ps.p_retailprice
FROM partsupp_supplier_part ps
WHERE ps.p_retailprice > (
    SELECT MAX(ps2.p_retailprice) FROM partsupp_supplier_part ps2 WHERE ps2.p_size = 15
);

-- Q068: Orders where all lineitems have quantity less than 30
SELECT DISTINCT lo.l_orderkey
FROM lineitem_orders lo
WHERE lo.l_orderkey NOT IN (
    SELECT l2.l_orderkey FROM lineitem_orders l2 WHERE l2.l_quantity >= 30
);

-- Q069: Suppliers with no parts having supply cost above 500
SELECT DISTINCT ps.ps_suppkey, ps.s_name
FROM partsupp_supplier_part ps
WHERE ps.ps_suppkey NOT IN (
    SELECT ps2.ps_suppkey FROM partsupp_supplier_part ps2 WHERE ps2.ps_supplycost > 500
);

-- Q070: Orders containing parts also supplied by suppliers from 'JAPAN'
SELECT DISTINCT lo.l_orderkey
FROM lineitem_orders lo
WHERE EXISTS (
    SELECT 1 FROM partsupp_supplier_part ps
    JOIN nation n ON ps.s_nationkey = n.n_nationkey
    WHERE ps_partkey = lo.l_partkey AND n_name = 'JAPAN'
);

-- Q071: Parts that are only supplied by suppliers from 'UNITED STATES'
SELECT ps.ps_partkey, ps.p_name
FROM partsupp_supplier_part ps
WHERE NOT EXISTS (
    SELECT 1 FROM partsupp_supplier_part psa
    JOIN nation n ON psa.s_nationkey = n.n_nationkey
    WHERE psa.ps_partkey = ps.ps_partkey AND n.n_name != 'UNITED STATES'
);

-- Q072: Customers who placed orders with totalprice higher than 50000 and with at least one lineitem with discount > 0.05
SELECT DISTINCT c.c_custkey, c.c_name
FROM customer c
WHERE EXISTS (
    SELECT 1 FROM lineitem_orders lo
    WHERE lo.o_custkey = c.c_custkey AND lo.o_totalprice > 50000 AND lo.l_discount > 0.05
);

-- Q073: Orders for which all lineitems were shipped via 'AIR'
SELECT DISTINCT lo.l_orderkey
FROM lineitem_orders lo
WHERE lo.l_orderkey NOT IN (
    SELECT lo2.l_orderkey FROM lineitem_orders lo2 WHERE lo2.l_shipmode != 'AIR'
);

-- Q074: Suppliers who do not supply any parts with brand 'Brand#23'
SELECT DISTINCT ps.ps_suppkey, ps.s_name
FROM partsupp_supplier_part ps
WHERE ps.ps_suppkey NOT IN (
    SELECT ps2.ps_suppkey FROM partsupp_supplier_part ps2 WHERE ps2.p_brand = 'Brand#23'
);

-- Q075: Customers with no orders in 1995
SELECT c.c_custkey, c.c_name
FROM customer c
WHERE NOT EXISTS (
    SELECT 1 FROM lineitem_orders lo
    WHERE lo.o_custkey = c.c_custkey AND lo.o_orderdate BETWEEN DATE '1995-01-01' AND DATE '1995-12-31'
);

-- Q076: Parts with size greater than the average size of parts in 'MED BOX' container
SELECT ps.ps_partkey, ps.p_size
FROM partsupp_supplier_part ps
WHERE ps.p_size > (
    SELECT AVG(ps2.p_size) FROM partsupp_supplier_part ps2 WHERE ps2.p_container = 'MED BOX'
);

-- Q077: Customers with higher balance than the customer named 'Customer#000000001'
SELECT c.c_custkey, c.c_name, c.c_acctbal
FROM customer c
WHERE c.c_acctbal > (
    SELECT c2.c_acctbal FROM customer c2 WHERE c2.c_name = 'Customer#000000001'
);

-- Q078: Orders that do not include any parts with size less than 5
SELECT DISTINCT lo.l_orderkey
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey
WHERE lo.l_orderkey NOT IN (
    SELECT lo2.l_orderkey FROM lineitem_orders lo2
    JOIN partsupp_supplier_part ps2 ON lo2.l_partkey = ps2.ps_partkey
    WHERE ps2.p_size < 5
);

-- Q079: Suppliers with more than one part supplied with container = 'LG CASE'
SELECT ps.ps_suppkey, ps.s_name
FROM partsupp_supplier_part ps
GROUP BY ps.ps_suppkey, ps.s_name
HAVING COUNT(CASE WHEN ps.p_container = 'LG CASE' THEN 1 END) > 1;

-- Q080: Orders that include only parts from the brand 'Brand#45'
SELECT DISTINCT lo.l_orderkey
FROM lineitem_orders lo
JOIN partsupp_supplier_part ps ON lo.l_partkey = ps.ps_partkey
WHERE lo.l_orderkey NOT IN (
    SELECT lo2.l_orderkey
    FROM lineitem_orders lo2
    JOIN partsupp_supplier_part ps2 ON lo2.l_partkey = ps2.ps_partkey
    WHERE ps2.p_brand != 'Brand#45'
);

-- Q081: Revenue calculation per region for parts of a specific brand with average discount above threshold
WITH avg_discount AS (
    SELECT p.p_brand, r.r_name AS region, AVG(l.l_discount) AS avg_disc
    FROM lineitem_orders l
    JOIN part p ON l.l_partkey = p.p_partkey
    JOIN supplier s ON l.l_suppkey = s.s_suppkey
    JOIN nation n ON s.s_nationkey = n.n_nationkey
    JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE p.p_brand = 'Brand#23'
    GROUP BY p.p_brand, r.r_name
)
SELECT * FROM avg_discount WHERE avg_disc > 0.04;

-- Q082: Rank customers by total spend in a given market segment
WITH customer_spend AS (
    SELECT c.c_name, c.c_mktsegment, SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_spent
    FROM customer c
    JOIN lineitem_orders l ON c.c_custkey = l.o_custkey
    WHERE c.c_mktsegment = 'BUILDING'
    GROUP BY c.c_name, c.c_mktsegment
)
SELECT *,
       RANK() OVER (PARTITION BY c_mktsegment ORDER BY total_spent DESC) AS rank
FROM customer_spend;

-- Q083: Find parts with suppliers in every region
WITH all_regions AS (
    SELECT r_regionkey FROM region
),
part_regions AS (
    SELECT DISTINCT p.p_partkey, r.r_regionkey
    FROM part p
    JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
    JOIN supplier s ON ps.ps_suppkey = s.s_suppkey
    JOIN nation n ON s.s_nationkey = n.n_nationkey
    JOIN region r ON n.n_regionkey = r.r_regionkey
)
SELECT p_partkey
FROM part_regions pr
GROUP BY p_partkey
HAVING COUNT(DISTINCT r_regionkey) = (SELECT COUNT(*) FROM all_regions);

-- Q084: Calculate average shipping delay per order
SELECT l.l_orderkey,
       AVG(date_diff('day', l.l_shipdate, l.l_receiptdate)) AS avg_shipping_delay
FROM lineitem_orders l
WHERE l.o_orderdate >= DATE '1994-01-01'
GROUP BY l.l_orderkey;

-- Q085: CTE + aggregate + string manipulation to get supplier list per part
WITH supplier_names AS (
    SELECT p.p_partkey, GROUP_CONCAT(DISTINCT s.s_name) AS suppliers
    FROM part p
    JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
    JOIN supplier s ON ps.ps_suppkey = s.s_suppkey
    GROUP BY p.p_partkey
)
SELECT * FROM supplier_names
WHERE LENGTH(suppliers) < 100;

-- Q086: CTE with filtering, grouping, and HAVING to find high-quantity part orders
WITH part_order_qty AS (
    SELECT p.p_partkey, p.p_name, SUM(l.l_quantity) AS total_qty
    FROM lineitem_orders l
    JOIN part p ON l.l_partkey = p.p_partkey
    GROUP BY p.p_partkey, p.p_name
)
SELECT * FROM part_order_qty
WHERE total_qty > 1000;

-- Q087: Rank orders by total lineitem value using window function
WITH order_totals AS (
    SELECT l.l_orderkey, SUM(l.l_extendedprice * (1 - l.l_discount)) AS order_value
    FROM lineitem_orders l
    GROUP BY l.l_orderkey
)
SELECT l_orderkey, order_value,
       RANK() OVER (ORDER BY order_value DESC) AS order_rank
FROM order_totals;

-- Q088: Subquery in WHERE clause to filter parts with supply cost above average
SELECT ps.ps_partkey, ps.ps_supplycost
FROM partsupp ps
WHERE ps.ps_supplycost > (
    SELECT AVG(ps2.ps_supplycost) FROM partsupp ps2
);

-- Q089: Aggregate and filter customer count by market segment
SELECT c.c_mktsegment, COUNT(*) AS customer_count
FROM customer c
GROUP BY c.c_mktsegment
HAVING COUNT(*) > 100;

-- Q090: CTE with filtering and aggregation on supplier account balance
WITH rich_suppliers AS (
    SELECT s.s_suppkey, s.s_name, s.s_acctbal
    FROM supplier s
    WHERE s.s_acctbal > 5000
)
SELECT COUNT(*) AS rich_count, AVG(s_acctbal) AS avg_rich_balance
FROM rich_suppliers;

-- Q091: Find top 5 parts by total revenue using LIMIT and ORDER BY inside a CTE
WITH part_revenue AS (
    SELECT p.p_partkey, p.p_name, SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
    FROM lineitem_orders l
    JOIN part p ON l.l_partkey = p.p_partkey
    GROUP BY p.p_partkey, p.p_name
)
SELECT * FROM part_revenue
ORDER BY revenue DESC
LIMIT 5;

-- Q092: Use window functions to compute running total revenue per supplier
SELECT s.s_suppkey, s.s_name,
       SUM(l.l_extendedprice * (1 - l.l_discount)) OVER (
           PARTITION BY s.s_suppkey ORDER BY l.l_shipdate
       ) AS running_revenue
FROM lineitem_orders l
JOIN supplier s ON l.l_suppkey = s.s_suppkey;

-- Q093: Join orders with lineitems and use a subquery to filter by average quantity per order
SELECT l.l_orderkey, AVG(l.l_quantity) AS avg_qty
FROM lineitem_orders l
GROUP BY l.l_orderkey
HAVING AVG(l.l_quantity) > (
    SELECT AVG(l2.l_quantity) FROM lineitem_orders l2
);

-- Q094: Combine CTE and conditional logic to calculate part popularity based on quantity sold
WITH part_sales AS (
    SELECT p.p_partkey, SUM(l.l_quantity) AS total_qty
    FROM lineitem_orders l
    JOIN part p ON l.l_partkey = p.p_partkey
    GROUP BY p.p_partkey
)
SELECT p_partkey,
       CASE
           WHEN total_qty > 2000 THEN 'High'
           WHEN total_qty > 1000 THEN 'Medium'
           ELSE 'Low'
       END AS popularity
FROM part_sales;

-- Q095: Count orders per shipping mode and filter with HAVING
SELECT l.l_shipmode, COUNT(DISTINCT l.l_orderkey) AS order_count
FROM lineitem_orders l
GROUP BY l.l_shipmode
HAVING COUNT(DISTINCT l.l_orderkey) > 100;

-- Q096: Correlated subquery to find orders where total quantity > average for that customer
SELECT l.l_orderkey, l.o_custkey, SUM(l.l_quantity) AS total_qty
FROM lineitem_orders l
GROUP BY l.l_orderkey, l.o_custkey
HAVING SUM(l.l_quantity) > (
    SELECT AVG(l2.l_quantity)
    FROM lineitem_orders l2
    WHERE l2.o_custkey = l.o_custkey
);

-- Q097: Use a CTE to find the most frequent shipmode
WITH ship_counts AS (
    SELECT l.l_shipmode, COUNT(*) AS cnt
    FROM lineitem_orders l
    GROUP BY l.l_shipmode
)
SELECT l_shipmode
FROM ship_counts
ORDER BY cnt DESC
LIMIT 1;

-- Q098: CTE and CASE to bucket orders by total value tiers
WITH order_value AS (
    SELECT l.l_orderkey, SUM(l.l_extendedprice * (1 - l.l_discount)) AS val
    FROM lineitem_orders l
    GROUP BY l.l_orderkey
)
SELECT l_orderkey,
       CASE
           WHEN val >= 50000 THEN 'High'
           WHEN val >= 20000 THEN 'Medium'
           ELSE 'Low'
       END AS value_tier
FROM order_value;

-- Q099: Count distinct parts sold by supplier
SELECT s.s_suppkey, s.s_name, COUNT(DISTINCT ps.ps_partkey) AS parts_sold
FROM supplier s
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_suppkey, s.s_name;

-- Q100: Average price per part container type
SELECT p.p_container, AVG(p.p_retailprice) AS avg_price
FROM part p
GROUP BY p.p_container;

