import unittest

from app import SymptomsInput, predict


class PredictionTests(unittest.TestCase):
    def test_predict_valid_symptom(self):
        response = predict(SymptomsInput(symptoms=["itching"]))
        self.assertIn("disease", response)

    def test_predict_invalid_symptom(self):
        response = predict(SymptomsInput(symptoms=["not_a_real_symptom"]))
        self.assertIn("error", response)


if __name__ == "__main__":
    unittest.main()
