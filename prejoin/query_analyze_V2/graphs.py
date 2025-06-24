
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

def main():
    file_path = "Query_Analysis.xlsx"
    df = pd.read_excel(file_path)

    output_dir = "Query_Analysis_Graphs"
    os.makedirs(output_dir, exist_ok=True)

    feature_suffixes = [
        "Tables", "ColumnsUsed", "Joins", "Subqueries",
        "GroupBy", "Having", "Where", "OrderBy", "AggregateFunctions"
    ]

    # Calculate average values
    avg_data = {
        "Feature": [],
        "Normalized": [],
        "Intermediate": [],
        "Advanced": []
    }

    for feature in feature_suffixes:
        avg_data["Feature"].append(feature)
        avg_data["Normalized"].append(df[f"Normalized_{feature}"].mean())
        avg_data["Intermediate"].append(df[f"Intermediate_{feature}"].mean())
        avg_data["Advanced"].append(df[f"Advanced_{feature}"].mean())

    avg_df = pd.DataFrame(avg_data)

    # Overall comparison chart
    plt.figure(figsize=(12, 6))
    avg_df.set_index("Feature").plot(kind="bar", rot=45)
    plt.title("Average Feature Comparison Across Schema Versions")
    plt.ylabel("Average Count")
    plt.xlabel("Query Feature")
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, "average_comparison_all_versions.png"))
    plt.close()

    # Individual feature comparison charts
    for feature in feature_suffixes:
        plt.figure(figsize=(6, 4))
        values = {
            'Normalized': df[f'Normalized_{feature}'].mean(),
            'Intermediate': df[f'Intermediate_{feature}'].mean(),
            'Advanced': df[f'Advanced_{feature}'].mean()
        }
        sns.barplot(x=list(values.keys()), y=list(values.values()), palette='Set2')
        plt.title(f"Average {feature} Across Versions")
        plt.ylabel("Average Count")
        plt.xlabel("Version")
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, f"{feature}_avg_comparison_all_versions.png"))
        plt.close()

    # Correlation heatmap
    plt.figure(figsize=(14, 10))
    corr = df.drop(columns=["QueryId", "Category", "ExpectedOutput", "Description"]).corr()
    sns.heatmap(corr, annot=True, cmap='coolwarm', fmt=".2f", linewidths=0.5)
    plt.title("Correlation Heatmap of All Query Features")
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, "correlation_heatmap_all_versions.png"))
    plt.close()

    print(f"Charts saved to {output_dir}")

if __name__ == "__main__":
    main()
