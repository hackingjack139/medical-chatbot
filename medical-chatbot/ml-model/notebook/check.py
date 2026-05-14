import pandas as pd

df = pd.read_csv("../data/Training.csv")

# 🔥 Remove unwanted columns
df = df.loc[:, ~df.columns.str.contains("^Unnamed")]

print("Shape:", df.shape)
print("Columns:", len(df.columns))
print("Last column:", df.columns[-1])
print(df.head())
