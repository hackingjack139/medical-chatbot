import pandas as pd

df = pd.read_csv("data/Training.csv")
df = df.loc[:, ~df.columns.str.contains("^Unnamed")]

symptoms_list = list(df.columns[:-1])  # remove prognosis

print(symptoms_list)
