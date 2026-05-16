#!/usr/bin/env bash

set -eu

NAMESPACE="${1:-medical-chatbot}"
FRONTEND_PORT="${2:-18080}"
BACKEND_PORT="${3:-18081}"

cleanup() {
  if [ -n "${FRONTEND_PF_PID:-}" ]; then
    kill "${FRONTEND_PF_PID}" >/dev/null 2>&1 || true
  fi
  if [ -n "${BACKEND_PF_PID:-}" ]; then
    kill "${BACKEND_PF_PID}" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

kubectl wait --for=condition=available deployment/frontend -n "${NAMESPACE}" --timeout=180s
kubectl wait --for=condition=available deployment/backend -n "${NAMESPACE}" --timeout=180s
kubectl wait --for=condition=available deployment/ml-model -n "${NAMESPACE}" --timeout=180s

kubectl port-forward -n "${NAMESPACE}" svc/frontend "${FRONTEND_PORT}:80" >/tmp/frontend-port-forward.log 2>&1 &
FRONTEND_PF_PID=$!
kubectl port-forward -n "${NAMESPACE}" svc/backend "${BACKEND_PORT}:8081" >/tmp/backend-port-forward.log 2>&1 &
BACKEND_PF_PID=$!

sleep 5

curl -fsS "http://127.0.0.1:${FRONTEND_PORT}" >/dev/null
curl -fsS "http://127.0.0.1:${BACKEND_PORT}/api/status" >/dev/null

kubectl get deployments -n "${NAMESPACE}"
kubectl get hpa -n "${NAMESPACE}" || true
