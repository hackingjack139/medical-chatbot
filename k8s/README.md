# Kubernetes Deployment

Apply manifests in this order:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/ml-model.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/hpa.yaml
```

Useful checks:

```bash
kubectl get all -n medical-chatbot
kubectl get hpa -n medical-chatbot
kubectl top pods -n medical-chatbot
kubectl describe pod -n medical-chatbot
```

Frontend is exposed with a NodePort on `30080`.

Notes:

- HPA works best when Metrics Server is available in the cluster.
- CPU requests and limits are defined in the deployment manifests so HPA can calculate utilization.
