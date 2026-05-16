#!/usr/bin/env bash

set -eu

IMAGE_TAG="${1:-latest}"
NAMESPACE="medical-chatbot"
ROLLOUT_STARTED="false"

FRONTEND_IMAGE="hackingjack139/medical-chatbot-frontend:${IMAGE_TAG}"
BACKEND_IMAGE="hackingjack139/medical-chatbot-backend:${IMAGE_TAG}"
ML_IMAGE="hackingjack139/medical-chatbot-ml:${IMAGE_TAG}"

rollback() {
  if [ "${ROLLOUT_STARTED}" = "true" ]; then
    echo "Deployment failed. Rolling back Kubernetes deployments..."
    kubectl rollout undo deployment/ml-model -n "${NAMESPACE}" || true
    kubectl rollout undo deployment/backend -n "${NAMESPACE}" || true
    kubectl rollout undo deployment/frontend -n "${NAMESPACE}" || true
  fi
}

trap rollback ERR

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/ml-model.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/fluent-bit.yaml

ROLLOUT_STARTED="true"
kubectl set image deployment/ml-model ml-model="${ML_IMAGE}" -n "${NAMESPACE}"
kubectl set image deployment/backend backend="${BACKEND_IMAGE}" -n "${NAMESPACE}"
kubectl set image deployment/frontend frontend="${FRONTEND_IMAGE}" -n "${NAMESPACE}"

kubectl rollout status deployment/ml-model -n "${NAMESPACE}" --timeout=180s
kubectl rollout status deployment/backend -n "${NAMESPACE}" --timeout=180s
kubectl rollout status deployment/frontend -n "${NAMESPACE}" --timeout=180s

kubectl get all -n "${NAMESPACE}"
kubectl get hpa -n "${NAMESPACE}"
