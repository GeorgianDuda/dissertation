
import pandas as pd
import duckdb
import matplotlib.pyplot as plt
import time
import os

# === CONFIG ===
query_file = "Queries.xlsx"
output_excel = "QueryPerformance_2Versions.xlsx"
output_category_summary = "QueryPerformance_ByCategory_2Versions.xlsx"
db_paths = {
    "Normalized": "C:/Workplace-Disertatie/DuckDb/normalised-sf50",
    "Denormalized": "C:/Workplace-Disertatie/DuckDb/denormalised-precalculate-sf50"
}

# === LOAD QUERIES ===
df = pd.read_excel(query_file)
versions = list(db_paths.keys())

# === EXECUTION TIMER ===
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
for version, db_path in db_paths.items():
    print(f"▶ Running queries for {version} on {db_path}")
    conn = duckdb.connect(database=db_path)
    times = []

    column_name = 'Normalised' if version == 'Normalized' else 'Denormalised'
    for i, query in enumerate(df[column_name]):
        if not isinstance(query, str) or query.strip() == "":
            times.append(None)
            continue
        elapsed = get_execution_time_ms(conn, query)
        print(f"⏱️ Query {i+1} → {elapsed:.2f} ms")
        times.append(elapsed)

    conn.close()
    df[f"{version}_ExecTime"] = times

# === SPEEDUP COMPUTATION ===
df["Speedup_Denormalized_vs_Normalized"] = df["Normalized_ExecTime"] / df["Denormalized_ExecTime"]

# === SAVE RESULTS ===
df.to_excel(output_excel, index=False)
print(f"✅ Saved query-level results to: {output_excel}")

# === PLOTS OUTPUT DIR ===
os.makedirs("Query_Analysis_Graphs", exist_ok=True)

# === OVERALL EXECUTION TIME PLOT ===
summary_df = pd.DataFrame({
    "Version": versions,
    "Avg Exec Time": [df[f"{v}_ExecTime"].mean() / 1000 for v in versions]
})

plt.figure(figsize=(8, 5))
plt.bar(summary_df["Version"], summary_df["Avg Exec Time"], color=['#4C72B0', '#55A868'])
plt.title("Average Execution Time per Schema Version")
plt.ylabel("Time (s)")
plt.xlabel("Schema Version")
plt.tight_layout()
plt.savefig("Query_Analysis_Graphs/exec_time_by_version.png")
plt.close()

# === SPEEDUP PLOT ===
plt.figure(figsize=(8, 5))
plt.bar(["Denormalized vs Normalized"], [df["Speedup_Denormalized_vs_Normalized"].mean()])
plt.title("Average Speedup of Denormalized vs Normalized")
plt.ylabel("Speedup (x times faster)")
plt.tight_layout()
plt.savefig("Query_Analysis_Graphs/speedup_vs_normalized.png")
plt.close()

# === CATEGORY BREAKDOWN ===
if 'Category' in df.columns:
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
    pivot = pivot[versions]

    pivot.plot(kind='bar', figsize=(10, 6), title="Avg Execution Time per Category")
    plt.ylabel("Execution Time (s)")
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig("Query_Analysis_Graphs/category_exec_time.png")
    plt.close()

    print(f"📊 Saved category breakdown to: {output_category_summary}")
