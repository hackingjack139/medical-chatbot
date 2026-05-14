from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import pickle
import numpy as np
import pandas as pd
import difflib

app = FastAPI()

# Load model
with open("model/disease_model.pkl", "rb") as f:
    model = pickle.load(f)

# Load dataset
df = pd.read_csv("data/Training.csv")
df = df.loc[:, ~df.columns.str.contains("^Unnamed")]

# Extract symptom columns
symptom_columns = list(df.columns[:-1])

# Normalize symptom names
normalized_symptoms = [s.lower().replace(" ", "_") for s in symptom_columns]

# Input schema
class SymptomsInput(BaseModel):
    symptoms: List[str]

@app.get("/")
def home():
    return {"message": "Medical ML API is running"}

@app.post("/predict")
def predict(data: SymptomsInput):
    try:
        # Create zero vector
        input_vector = [0] * len(symptom_columns)

        # Process input symptoms
        for symptom in data.symptoms:
            cleaned = symptom.lower().replace(" ", "_")

            if cleaned in normalized_symptoms:
                index = normalized_symptoms.index(cleaned)
                input_vector[index] = 1
            else:
                # Suggest closest match
                suggestion = difflib.get_close_matches(cleaned, normalized_symptoms, n=1)

                if suggestion:
                    return {
                        "error": f"Invalid symptom: {symptom}",
                        "did_you_mean": suggestion[0]
                    }
                else:
                    return {
                        "error": f"Invalid symptom: {symptom}"
                    }

        # Convert to numpy
        input_data = np.array(input_vector).reshape(1, -1)

        prediction = model.predict(input_data)

        return {
            "disease": prediction[0]
        }

    except Exception as e:
        return {
            "error": str(e)
        }
