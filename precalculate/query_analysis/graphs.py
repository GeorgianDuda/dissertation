
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

def main():
    # Load the data
    file_path = "Query_Analysis.xlsx"
    df = pd.read_excel(file_path)

    # Create output directory
    output_dir = "Query_Analysis_Graphs"
    os.makedirs(output_dir, exist_ok=True)

    # Define the features to analyze
    feature_suffixes = [
        "Tables", "ColumnsUsed", "Joins", "Subqueries",
        "GroupBy", "Having", "Where", "OrderBy", "AggregateFunctions"
    ]

    # Calculate average values
    avg_data = {
        "Feature": [],
        "Normalized": [],
        "Denormalized": []
    }

    for feature in feature_suffixes:
        avg_data["Feature"].append(feature)
        avg_data["Normalized"].append(df[f"Normalized_{feature}"].mean())
        avg_data["Denormalized"].append(df[f"Denormalized_{feature}"].mean())

    avg_df = pd.DataFrame(avg_data)

    # Overall comparison chart
    plt.figure(figsize=(12, 6))
    avg_df.set_index("Feature").plot(kind="bar", rot=45)
    plt.title("Average Feature Comparison: Normalized vs Denormalized")
    plt.ylabel("Average Count")
    plt.xlabel("Query Feature")
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, "average_comparison.png"))
    plt.close()

    # Individual feature comparison charts
    for feature in feature_suffixes:
        plt.figure(figsize=(6, 4))
        values = {
            'Normalized': df[f'Normalized_{feature}'].mean(),
            'Denormalized': df[f'Denormalized_{feature}'].mean()
        }
        sns.barplot(x=list(values.keys()), y=list(values.values()), palette='Set2')
        plt.title(f"Average {feature}: Normalized vs Denormalized")
        plt.ylabel("Average Count")
        plt.xlabel("Version")
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, f"{feature}_avg_comparison.png"))
        plt.close()

    # Correlation heatmap
    plt.figure(figsize=(14, 10))
    corr = df.drop(columns=["QueryId", "Description"]).corr()
    sns.heatmap(corr, annot=True, cmap='coolwarm', fmt=".2f", linewidths=0.5)
    plt.title("Correlation Heatmap of Query Features")
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, "correlation_heatmap.png"))
    plt.close()

    print(f"Charts saved to {output_dir}")

if __name__ == "__main__":
    main()
