import pandas as pd

print("Reading score.csv...")

# Read CSV created by SAS
df = pd.read_csv(
    r"C:\Users\z0059emp\Documents\Workbench Workspaces\Demo_Workspace\score.csv"
)

print("\nOriginal Dataset:")
print(df)

# Create rank based on Score (highest score = rank 1)
df["Rank"] = df["Score"].rank(
    method="dense",
    ascending=False
).astype(int)

# Sort by rank
df = df.sort_values("Rank")

print("\nDataset with Rank:")
print(df)

# Save ranked dataset for R
output_file = (
    r"C:\Users\z0059emp\Documents\Workbench Workspaces"
    r"\Demo_Workspace\ranked_scores.csv"
)

df.to_csv(
    output_file,
    index=False
)

print(f"\nCreated {output_file}")

print("\nPython processing complete.")