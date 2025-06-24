import pandas as pd
import duckdb
import matplotlib.pyplot as plt
import time

# === CONFIG ===
query_file = "Queries.xlsx"
sheet_name = "Queries"
output_excel = "QueryPerformance_MultiDB.xlsx"
output_category_summary = "QueryPerformance_ByCategory_MultiDB.xlsx"

# Schema versions and corresponding DuckDB databases
version_db_map = {
    "Normalised": "C:/Workplace-Disertatie/DuckDb/normalised-sf50",
    "Prejoined_Intermediate": "C:/Workplace-Disertatie/DuckDb/denormalised-prejoin-intermediate-sf50",
    "Prejoined_Advanced": "C:/Workplace-Disertatie/DuckDb/denormalised-prejoin-advanced-sf50"
}

# === LOAD QUERIES ===
df = pd.read_excel(query_file, sheet_name=sheet_name)
versions = list(version_db_map.keys())

# === MANUAL TIMING FUNCTION ===
def get_execution_time_ms(conn, query):
    try:
        start = time.perf_counter()
        conn.execute(query)
        end = time.perf_counter()
        return (end - start) * 1000  # ms
    except Exception as e:
        print(f"⚠️ Query error: {e}")
        return None

# === RUN QUERIES ===
for version, db_path in version_db_map.items():
    print(f"\n▶ Running queries for {version} on {db_path}")
    conn = duckdb.connect(database=db_path)
    times = []

    for i, query in enumerate(df[version]):
        if not isinstance(query, str) or query.strip() == "":
            times.append(None)
            continue
        elapsed = get_execution_time_ms(conn, query)
        print(f"⏱️ Query {i+1} → {elapsed:.2f} ms")
        times.append(elapsed)
    conn.close()
    df[f"{version}_ExecTime"] = times

# === COMPUTE SPEEDUPS ===
df['Speedup_Intermediate_vs_Normalised'] = (
    df['Normalised_ExecTime'] / df['Prejoined_Intermediate_ExecTime']
)
df['Speedup_Advanced_vs_Normalised'] = (
    df['Normalised_ExecTime'] / df['Prejoined_Advanced_ExecTime']
)

# === SAVE DETAILED RESULTS ===
df.to_excel(output_excel, index=False)
print(f"\n✅ Saved detailed execution results to: {output_excel}")

# === OVERALL SUMMARY PLOT ===
summary = {
    "Version": [],
    "Avg Exec Time": []
}
for version in versions:
    summary["Version"].append(version)
    summary["Avg Exec Time"].append(df[f"{version}_ExecTime"].mean() / 1000)  # ms → s

summary_df = pd.DataFrame(summary)

plt.figure(figsize=(8, 5))
plt.bar(summary_df["Version"], summary_df["Avg Exec Time"])
plt.title("Average Execution Time per Schema Version")
plt.ylabel("Time (s)")
plt.xlabel("Schema Version")
plt.tight_layout()
plt.savefig("exec_time_by_version.png")
plt.show()

# === SPEEDUP PLOT ===
plt.figure(figsize=(8, 5))
plt.bar(["Intermediate vs Normalised", "Advanced vs Normalised"], [
    df['Speedup_Intermediate_vs_Normalised'].mean(),
    df['Speedup_Advanced_vs_Normalised'].mean()
])
plt.title("Average Speedup vs Normalised")
plt.ylabel("Speedup (x times faster)")
plt.tight_layout()
plt.savefig("speedup_vs_normalized.png")
plt.show()

# === CATEGORY-LEVEL BREAKDOWN ===
cat_data = []
for category in df['Category'].dropna().unique():
    sub = df[df['Category'] == category]
    for version in versions:
        cat_data.append({
            'Category': category,
            'Version': version,
            'Avg Exec Time': sub[f"{version}_ExecTime"].mean() / 1000  # ms → s
        })

cat_df = pd.DataFrame(cat_data)
cat_df.to_excel(output_category_summary, index=False)

pivot = cat_df.pivot(index='Category', columns='Version', values='Avg Exec Time')
pivot = pivot[['Normalised', 'Prejoined_Intermediate', 'Prejoined_Advanced']]  # enforce column order

pivot.plot(kind='bar', figsize=(10, 6), title="Avg Execution Time per Category")
plt.ylabel("Execution Time (s)")
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig("category_exec_time.png")
plt.show()

print(f"\n📊 Saved category summary to: {output_category_summary}")
