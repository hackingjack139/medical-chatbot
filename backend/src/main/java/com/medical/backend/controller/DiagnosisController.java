package com.medical.backend.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class DiagnosisController {

    @Value("${ml.service.url:http://localhost:8000/predict}")
    private String mlServiceUrl;

    @Value("${BACKEND_SHARED_SECRET:}")
    private String backendSharedSecret;

    @PostMapping("/diagnose")
    public Map<String, Object> diagnose(@RequestBody Map<String, List<String>> request) {

        List<String> symptoms = request.get("symptoms");

        RestTemplate restTemplate = new RestTemplate();

        Map<String, Object> mlRequest = new HashMap<>();
        mlRequest.put("symptoms", symptoms);

        Map response = restTemplate.postForObject(mlServiceUrl, mlRequest, Map.class);

        return response;
    }

    // 🔥 NEW API FOR DROPDOWN
    @GetMapping("/symptoms")
    public List<String> getSymptoms() {
        return List.of(
                "itching",
                "skin_rash",
                "nodal_skin_eruptions",
                "continuous_sneezing",
                "shivering",
                "chills",
                "joint_pain",
                "stomach_pain",
                "acidity",
                "ulcers_on_tongue",
                "muscle_wasting",
                "vomiting",
                "burning_micturition",
                "spotting_urination",
                "fatigue",
                "weight_gain",
                "anxiety",
                "cold_hands_and_feets",
                "mood_swings",
                "weight_loss",
                "restlessness",
                "lethargy",
                "patches_in_throat",
                "irregular_sugar_level",
                "cough",
                "high_fever",
                "sunken_eyes",
                "yellowish_skin",
                "headache"
        );
    }

    @GetMapping("/status")
    public Map<String, Object> status() {
        Map<String, Object> status = new HashMap<>();
        status.put("mlServiceUrlConfigured", mlServiceUrl != null && !mlServiceUrl.isBlank());
        status.put("sharedSecretConfigured", backendSharedSecret != null && !backendSharedSecret.isBlank());
        return status;
    }
}
