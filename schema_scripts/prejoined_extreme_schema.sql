
-- Extreme Prejoin: lineitem_orders_customer_nation_region
CREATE TABLE lineitem_orders_customer_nation_region AS
SELECT
    l.*,o.o_orderstatus,o.o_totalprice,o.o_orderdate,o.o_orderpriority, o.o_clerk,
    c.c_custkey,c.c_name,c.c_address,c.c_nationkey,c.c_phone,c.c_acctbal,c.c_mktsegment,c.c_comment,
    n.n_nationkey,n.n_name,n.n_comment,
    r.r_regionkey,r.r_name,r.r_comment
FROM lineitem l
JOIN orders o ON l.l_orderkey = o.o_orderkey
JOIN customer c ON o.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey;

-- Extreme Prejoin: lineitem_part_partsupp_supplier
CREATE TABLE lineitem_part_partsupp_supplier AS
SELECT
    l.*,p.p_name,p.p_mfgr,p.p_brand,p.p_type,p.p_size,p.p_container,p.p_retailprice,p.p_comment,
    ps.ps_availqty,ps.ps_supplycost,ps.ps_comment,
    s.s_name,s.s_address,s.s_nationkey,s.s_phone,s.s_acctbal,s.s_comment
FROM lineitem l
JOIN part p ON l.l_partkey = p.p_partkey
JOIN partsupp ps ON l.l_partkey = ps.ps_partkey AND l.l_suppkey = ps.ps_suppkey
JOIN supplier s ON l.l_suppkey = s.s_suppkey;
