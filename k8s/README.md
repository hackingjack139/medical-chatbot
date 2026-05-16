# Kubernetes Deployment

Apply manifests in this order:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/ml-model.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/fluent-bit.yaml
```

Useful checks:

```bash
kubectl get all -n medical-chatbot
kubectl get hpa -n medical-chatbot
kubectl top pods -n medical-chatbot
kubectl describe pod -n medical-chatbot
```

Frontend is exposed with a NodePort on `30080`.

Pipeline deployment:

```bash
./k8s/deploy.sh <image-tag>
```

Pipeline verification:

```bash
./k8s/verify.sh medical-chatbot
```

Notes:

- HPA works best when Metrics Server is available in the cluster.
- CPU requests and limits are defined in the deployment manifests so HPA can calculate utilization.
- Frontend and ML deployments now include `startupProbe`, `readinessProbe`, and `livenessProbe`.
- Backend probes use `/api/status` so Kubernetes checks a lightweight health endpoint rather than a business endpoint.
- Jenkins can deploy to Kubernetes when the Jenkins runtime has `kubectl` installed and valid cluster access.
- The Kubernetes deploy script automatically runs `kubectl rollout undo` if a rollout fails after image update.
- The Kubernetes verify script checks deployment availability and validates frontend and backend access through temporary port-forwarding.
- Kubernetes pod logs are shipped by Fluent Bit to Logstash over TCP and then indexed into Elasticsearch for Kibana discovery.
- The provided Fluent Bit setup is tuned for Docker Desktop style local clusters using `host.docker.internal` as the Logstash host.
