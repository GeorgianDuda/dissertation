import pandas as pd
import re
import matplotlib.pyplot as plt

# === Step 1: Load your Excel file ===
file_path = "Queries.xlsx"  # change this to your file path
sheet_name = "Queries"
df = pd.read_excel(file_path, sheet_name=sheet_name)

# === Step 2: Helper functions ===
def extract_table_mentions(query: str) -> list:
    if not isinstance(query, str):
        return []
    matches = re.findall(r'\b(?:FROM|JOIN)\s+([a-zA-Z0-9_\.]+)', query, re.IGNORECASE)
    return list(set(matches))

def estimate_complexity(query: str) -> int:
    if not isinstance(query, str):
        return 0
    joins = len(re.findall(r'\bJOIN\b', query, re.IGNORECASE))
    filters = len(re.findall(r'\bWHERE\b', query, re.IGNORECASE))
    groups = len(re.findall(r'\bGROUP BY\b', query, re.IGNORECASE))
    orders = len(re.findall(r'\bORDER BY\b', query, re.IGNORECASE))
    subqueries = len(re.findall(r'\bSELECT\b', query, re.IGNORECASE)) - 1
    distincts = len(re.findall(r'\bDISTINCT\b', query, re.IGNORECASE))
    return joins + filters + groups + orders + subqueries + distincts

# === Step 3: Analyze query versions ===
versions = ['Normalised', 'Prejoined_Intermediate', 'Prejoined_Advanced']
for version in versions:
    df[f'{version}_Tables'] = df[version].apply(extract_table_mentions)
    df[f'{version}_TableCount'] = df[f'{version}_Tables'].apply(len)
    df[f'{version}_Complexity'] = df[version].apply(estimate_complexity)

# === Step 4: Plot average complexity and table count overall ===
summary_data = {
    'Version': [],
    'Avg Complexity': [],
    'Avg Table Count': []
}
for version in versions:
    summary_data['Version'].append(version)
    summary_data['Avg Complexity'].append(df[f'{version}_Complexity'].mean())
    summary_data['Avg Table Count'].append(df[f'{version}_TableCount'].mean())

summary_df = pd.DataFrame(summary_data)

# Global complexity plot
plt.figure(figsize=(8, 5))
plt.bar(summary_df['Version'], summary_df['Avg Complexity'])
plt.title("Average Query Complexity per Schema Version")
plt.ylabel("Complexity Score")
plt.xlabel("Schema Version")
plt.tight_layout()
plt.savefig("avg_complexity.png")
plt.show()

# Global table count plot
plt.figure(figsize=(8, 5))
plt.bar(summary_df['Version'], summary_df['Avg Table Count'])
plt.title("Average Number of Tables Used per Schema Version")
plt.ylabel("Number of Tables")
plt.xlabel("Schema Version")
plt.tight_layout()
plt.savefig("avg_table_count.png")
plt.show()

# === Step 5: Category-level breakdown ===
category_summary = []

for category in df['Category'].dropna().unique():
    sub_df = df[df['Category'] == category]
    for version in versions:
        category_summary.append({
            'Category': category,
            'Version': version,
            'Avg Complexity': sub_df[f'{version}_Complexity'].mean(),
            'Avg Table Count': sub_df[f'{version}_TableCount'].mean()
        })

cat_df = pd.DataFrame(category_summary)

# Category-level complexity plot
pivot_cmplx = cat_df.pivot(index='Category', columns='Version', values='Avg Complexity')
pivot_cmplx = pivot_cmplx[['Normalised', 'Prejoined_Intermediate', 'Prejoined_Advanced']] 
pivot_cmplx.plot(kind='bar', figsize=(10, 6), title="Avg Complexity per Category", ylabel="Complexity")
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig("category_complexity.png")
plt.show()

# Category-level table count plot
pivot_tbls = cat_df.pivot(index='Category', columns='Version', values='Avg Table Count')
pivot_tbls = pivot_tbls[['Normalised', 'Prejoined_Intermediate', 'Prejoined_Advanced']] 
pivot_tbls.plot(kind='bar', figsize=(10, 6), title="Avg Table Count per Category", ylabel="Tables Used")
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig("category_table_count.png")
plt.show()

# === Step 6: Save full analysis ===
output_file = "QueryAnalysis_Results.xlsx"
df.to_excel(output_file, index=False)
cat_df.to_excel("Category_Summary.xlsx", index=False)
print("Analysis complete:")
print(f"- Query results saved to: {output_file}")
print(f"- Category summary saved to: Category_Summary.xlsx")
print(f"- Plots saved: avg_complexity.png, avg_table_count.png, category_complexity.png, category_table_count.png")
