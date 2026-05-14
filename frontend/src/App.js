import { useState, useEffect } from "react";
import Select from "react-select";
import "./App.css";

function App() {
  const [options, setOptions] = useState([]);
  const [selected, setSelected] = useState([]);
  const [result, setResult] = useState("");
  const [loading, setLoading] = useState(false);

  // Fetch symptoms
  useEffect(() => {
    fetch("http://localhost:8081/api/symptoms")
      .then(res => res.json())
      .then(data => {
        const formatted = data.map(s => ({
          value: s,
          label: s.replaceAll("_", " ").replace(/\b\w/g, l => l.toUpperCase())
        }));
        setOptions(formatted);
      });
  }, []);

  const handleSubmit = async () => {
    setLoading(true);
    setResult("");

    const symptoms = selected.map(s => s.value);

    try {
      const response = await fetch("http://localhost:8081/api/diagnose", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ symptoms }),
      });

      const data = await response.json();

      if (data.disease) {
        setResult(data.disease);
      } else {
        setResult(data.error);
      }

    } catch (err) {
      setResult("Error connecting to server");
    }

    setLoading(false);
  };

  return (
    <div className="container">
      <div className="card">
        <h1>🩺 Medical Chatbot</h1>

        <p>Select or type symptoms</p>

        <Select
          options={options}
          isMulti
          value={selected}
          onChange={setSelected}
          placeholder="Type or select symptoms..."
        />

        <button onClick={handleSubmit} disabled={loading || selected.length === 0}>
          {loading ? "Predicting..." : "Predict Disease"}
        </button>

        {result && (
          <div className="result">
            <h3>Possible Condition:</h3>
            <p style={{ fontSize: "12px", color: "gray" }}>
            This is a machine learning prediction and not a medical diagnosis.
            </p>
            <p>{result}</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
