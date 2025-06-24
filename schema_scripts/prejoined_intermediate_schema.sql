
-- Intermediate Prejoin: lineitem_orders
CREATE TABLE lineitem_orders AS
SELECT
    l.*,o.o_custkey,o.o_orderstatus,o.o_totalprice,o.o_orderdate,
    o.o_orderpriority,o.o_clerk,o.o_shippriority,o.o_comment,
FROM lineitem l
JOIN orders o ON l.l_orderkey = o.o_orderkey;

-- Intermediate Prejoin: partsupp_supplier
CREATE TABLE partsupp_supplier_part AS
SELECT
    ps.*,s.s_name,s.s_address,s.s_nationkey,s.s_phone,s.s_acctbal,s.s_comment,
    p.p_name,p.p_mfgr,p.p_brand,p.p_type,p.p_size,p.p_container,p.p_retailprice,p.p_comment,
FROM partsupp ps
JOIN supplier s ON ps.ps_suppkey = s.s_suppkey
join part p on ps.ps_partkey = p.p_partkey;
