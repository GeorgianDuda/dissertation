
-- Precomputed Columns

-- Orders table
ALTER TABLE orders ADD COLUMN o_avg_discount NUMERIC;
UPDATE orders o SET 
    o_avg_discount = (
        SELECT AVG(l.l_discount)
        FROM lineitem l
        WHERE l.l_orderkey = o.o_orderkey
    );

ALTER TABLE orders ADD COLUMN o_total_lineitems INTEGER;
UPDATE orders SET
    o_total_lineitems = (
        SELECT COUNT(*) FROM lineitem l WHERE l.l_orderkey = orders.o_orderkey
    );

-- Customer table
ALTER TABLE customer ADD COLUMN c_total_spent NUMERIC;
ALTER TABLE customer ADD COLUMN c_number_of_orders INTEGER;
UPDATE customer c SET
    c_total_spent = (
        SELECT SUM(o.o_totalprice)
        FROM orders o
        WHERE o.o_custkey = c.c_custkey
    ),
    c_number_of_orders = (
        SELECT COUNT(*)
        FROM orders o
        WHERE o.o_custkey = c.c_custkey
    );

-- Supplier table
ALTER TABLE supplier ADD COLUMN s_total_supply_cost NUMERIC;
ALTER TABLE supplier ADD COLUMN s_total_parts_supplied INTEGER;
ALTER TABLE supplier ADD COLUMN s_avg_supply_cost DOUBLE;
UPDATE supplier s SET
    s_total_supply_cost = (
        SELECT SUM(ps.ps_supplycost * ps.ps_availqty)
        FROM partsupp ps
        WHERE ps.ps_suppkey = s.s_suppkey
    ),
    s_total_parts_supplied = (
        SELECT COUNT(*)
        FROM partsupp ps
        WHERE ps.ps_suppkey = s.s_suppkey
    ),
    s_avg_supply_cost = (
    SELECT AVG(ps.ps_supplycost)
    FROM partsupp ps
    WHERE ps.ps_suppkey = s.s_suppkey
);


-- Part
ALTER TABLE part ADD COLUMN p_total_sales_last_30_days DOUBLE;
UPDATE part SET p_total_sales_last_30_days = (
    SELECT SUM(l.l_extendedprice * (1 - l.l_discount))
    FROM lineitem l
    WHERE l.l_partkey = part.p_partkey
      AND l.l_shipdate >= CURRENT_DATE - INTERVAL 30 DAY
);

-- Nation
ALTER TABLE nation ADD COLUMN n_total_revenue DOUBLE;
UPDATE nation SET n_total_revenue = (
    SELECT SUM(o.o_totalprice)
    FROM customer c
    JOIN orders o ON o.o_custkey = c.c_custkey
    WHERE c.c_nationkey = nation.n_nationkey
);

-- Region
ALTER TABLE region ADD COLUMN r_order_count_1992 BIGINT DEFAULT 0;
ALTER TABLE region ADD COLUMN r_order_count_1993 BIGINT DEFAULT 0;
ALTER TABLE region ADD COLUMN r_order_count_1994 BIGINT DEFAULT 0;

UPDATE region SET
    r_order_count_1992 = (
        SELECT COUNT(*) FROM region r2
        JOIN nation n ON n.n_regionkey = r2.r_regionkey
        JOIN customer c ON c.c_nationkey = n.n_nationkey
        JOIN orders o ON o.o_custkey = c.c_custkey
        WHERE r2.r_regionkey = region.r_regionkey
          AND EXTRACT(YEAR FROM o.o_orderdate) = 1992
    ),
    r_order_count_1993 = (
        SELECT COUNT(*) FROM region r2
        JOIN nation n ON n.n_regionkey = r2.r_regionkey
        JOIN customer c ON c.c_nationkey = n.n_nationkey
        JOIN orders o ON o.o_custkey = c.c_custkey
        WHERE r2.r_regionkey = region.r_regionkey
          AND EXTRACT(YEAR FROM o.o_orderdate) = 1993
    ),
    r_order_count_1994 = (
        SELECT COUNT(*) FROM region r2
        JOIN nation n ON n.n_regionkey = r2.r_regionkey
        JOIN customer c ON c.c_nationkey = n.n_nationkey
        JOIN orders o ON o.o_custkey = c.c_custkey
        WHERE r2.r_regionkey = region.r_regionkey
          AND EXTRACT(YEAR FROM o.o_orderdate) = 1994
    );

