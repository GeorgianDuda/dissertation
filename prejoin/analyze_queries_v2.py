
import pandas as pd
import sqlparse
from sql_metadata import Parser
import re

error_log = []

def analyze_query(query: str, query_id: str, version: str):
    if not isinstance(query, str) or not query.strip():
        error_log.append({
            'QueryId': query_id,
            'Version': version,
            'Error': 'Empty or non-string query.',
            'Query': query
        })
        return {f"{version}_Tables": 0,
                f"{version}_ColumnsUsed": 0,
                f"{version}_Joins": 0,
                f"{version}_Subqueries": 0,
                f"{version}_GroupBy": 0,
                f"{version}_Having": 0,
                f"{version}_Where": 0,
                f"{version}_OrderBy": 0,
                f"{version}_AggregateFunctions": 0}

    try:
        parsed = sqlparse.parse(query)
        if not parsed:
            raise ValueError("Empty or unparseable SQL.")

        parser = Parser(query)
        tables = parser.tables
        columns = parser.columns_dict
        subqueries = query.lower().count('select') - 1
        join_count = query.lower().count(' join ')
        group_by_count = query.lower().count('group by')
        having_count = query.lower().count('having')
        order_by_count = query.lower().count('order by')
        agg_functions = sum(query.lower().count(func) for func in ['sum(', 'avg(', 'count(', 'min(', 'max('])

        where_clause = re.search(r'where\s+(.*?)(group by|order by|having|limit|$)', query, re.IGNORECASE | re.DOTALL)
        where_text = where_clause.group(1) if where_clause else ""

        and_count = where_text.lower().count(' and ')
        or_count = where_text.lower().count(' or ')
        comparison_ops = len(re.findall(r'(=|!=|<>|<=|>=|<|>)', where_text))
        like_count = where_text.lower().count(' like ')
        in_count = len(re.findall(r'\b(in)\s*\(', where_text.lower()))

        total_where_conditions = and_count + or_count + comparison_ops + like_count + in_count

        return {
            f"{version}_Tables": len(set(tables)),
            f"{version}_ColumnsUsed": sum(len(v) for v in columns.values()),
            f"{version}_Joins": join_count,
            f"{version}_Subqueries": subqueries,
            f"{version}_GroupBy": group_by_count,
            f"{version}_Having": having_count,
            f"{version}_Where": total_where_conditions,
            f"{version}_OrderBy": order_by_count,
            f"{version}_AggregateFunctions": agg_functions
        }
    except Exception as e:
        error_log.append({
            'QueryId': query_id,
            'Version': version,
            'Error': str(e),
            'Query': query
        })
        return {f"{version}_Tables": 0,
                f"{version}_ColumnsUsed": 0,
                f"{version}_Joins": 0,
                f"{version}_Subqueries": 0,
                f"{version}_GroupBy": 0,
                f"{version}_Having": 0,
                f"{version}_Where": 0,
                f"{version}_OrderBy": 0,
                f"{version}_AggregateFunctions": 0}

def main():
    df = pd.read_excel("Queries.xlsx")
    merged_analysis_data = []

    for _, row in df.iterrows():
        query_id = row.get('Query number') or row.get('QueryId') or f"Q{_+1}"

        norm_metrics = analyze_query(row['Normalised'], query_id, 'Normalized')
        inter_metrics = analyze_query(row['Prejoined_Intermediate'], query_id, 'Intermediate')
        adv_metrics = analyze_query(row['Prejoined_Advanced'], query_id, 'Advanced')

        merged_row = {
            'QueryId': query_id,
            'Category': row.get('Category'),
            'ExpectedOutput': row.get('Expected output'),
            'Description': row.get('Description')
        }
        merged_row.update(norm_metrics)
        merged_row.update(inter_metrics)
        merged_row.update(adv_metrics)

        merged_analysis_data.append(merged_row)

    final_df = pd.DataFrame(merged_analysis_data)
    final_df.to_excel("Query_Analysis.xlsx", index=False)
    print("✅ Analysis saved to Query_Analysis.xlsx")

    if error_log:
        error_df = pd.DataFrame(error_log)
        error_df.to_excel("Query_Analysis_Errors.xlsx", index=False)
        print(f"⚠️ {len(error_log)} queries had issues. See Query_Analysis_Errors.xlsx")

if __name__ == "__main__":
    main()
