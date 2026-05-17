# Medical Chatbot DevOps Platform

This repository contains a healthcare-domain application and the infrastructure built around it for CI/CD, deployment, orchestration, observability, and secret handling.

## Application

The app predicts a possible medical condition from selected symptoms.

Services:

- `frontend`: React UI
- `backend`: Spring Boot API
- `ml-model`: FastAPI inference service

Runtime flow:

`frontend -> backend -> ml-model -> prediction response`

## DevOps Stack

This project includes:

- Git + GitHub
- Jenkins pipeline with GitHub webhook trigger
- Docker and Docker Compose
- Ansible deployment automation
- Kubernetes manifests and HPA
- ELK observability stack
- Vault-backed deployment secrets

## Repository Layout

```text
frontend/         React UI
backend/          Spring Boot API
ml-model/         FastAPI model service
ansible/          Deployment playbook and role
k8s/              Kubernetes manifests and scripts
observability/    Elasticsearch, Logstash, Kibana setup
security/         Vault setup
jenkins/          Custom Jenkins runtime image
Jenkinsfile       CI/CD pipeline
docker-compose.yml
docker-compose.deploy.yml
```

## CI/CD Flow

1. Code is pushed to GitHub.
2. GitHub webhook triggers Jenkins.
3. Jenkins:
   - checks out code
   - runs frontend tests
   - runs backend tests
   - runs ML smoke tests
   - builds tagged Docker images
   - runs image security scans
   - pushes images to Docker Hub
   - deploys to either Docker Compose or Kubernetes
4. Post-deploy verification runs.
5. Rollback logic is available for both deployment modes.

## Jenkins Pipeline Features

Current pipeline improvements include:

- short commit-SHA image tagging
- `latest` plus immutable image tags
- Trivy image scanning for built images
- selectable deploy target:
  - `compose`
  - `kubernetes`
- post-deploy verification
- Compose rollback to previous deployed tag
- Kubernetes rollout undo on failed deployment

See:

- [`Jenkinsfile`](/Users/manzil/spe/Jenkinsfile)
- [`jenkins/Dockerfile`](/Users/manzil/spe/jenkins/Dockerfile)

## Deployment Modes

### 1. Docker Compose + Ansible

This is the current main application deployment path.

Jenkins can deploy the app stack through Ansible using:

- [`ansible/playbook.yml`](/Users/manzil/spe/ansible/playbook.yml)
- [`ansible/roles/deploy_medical_chatbot`](/Users/manzil/spe/ansible/roles/deploy_medical_chatbot)

### 2. Kubernetes + HPA

This path is available for orchestration and scaling validation.

Useful files:

- [`k8s/frontend.yaml`](/Users/manzil/spe/k8s/frontend.yaml)
- [`k8s/backend.yaml`](/Users/manzil/spe/k8s/backend.yaml)
- [`k8s/ml-model.yaml`](/Users/manzil/spe/k8s/ml-model.yaml)
- [`k8s/hpa.yaml`](/Users/manzil/spe/k8s/hpa.yaml)
- [`k8s/deploy.sh`](/Users/manzil/spe/k8s/deploy.sh)
- [`k8s/verify.sh`](/Users/manzil/spe/k8s/verify.sh)

## Local Run

### Docker Compose App Stack

```bash
docker compose up --build
```

Main ports:

- frontend: `http://localhost:3000`
- backend: `http://localhost:8081`
- ml-model: `http://localhost:8000`

### ELK Stack

```bash
docker compose -f observability/docker-compose.elk.yml up -d
```

Open:

- Elasticsearch: `http://localhost:9200`
- Kibana: `http://localhost:5601`

Suggested Kibana data view:

```text
medical-chatbot-logs-*
```

### Vault

Vault runs in Docker dev mode for local demonstration:

- endpoint: `http://localhost:8200`
- Jenkins compose deploys use `http://host.docker.internal:8200` to reach that same Vault service from inside the Jenkins container

See:

- [`security/README.md`](/Users/manzil/spe/security/README.md)

## Kubernetes Notes

If using Docker Desktop Kubernetes:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/ml-model.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/fluent-bit.yaml
```

Helpful checks:

```bash
kubectl get all -n medical-chatbot
kubectl get hpa -n medical-chatbot
kubectl top pods -n medical-chatbot
```

Frontend is exposed on NodePort `30080`, though local macOS Docker Desktop setups may prefer:

```bash
kubectl port-forward -n medical-chatbot svc/frontend 30080:80
```

## Observability Notes

Current observability paths:

- Docker Compose app logs -> Logstash -> Elasticsearch -> Kibana
- Kubernetes pod logs -> Fluent Bit -> Logstash -> Elasticsearch -> Kibana

See:

- [`observability/README.md`](/Users/manzil/spe/observability/README.md)
- [`k8s/fluent-bit.yaml`](/Users/manzil/spe/k8s/fluent-bit.yaml)

## Security Notes

Deployment secrets are read from Vault and rendered into runtime configuration by Ansible.

Vault is now intended to be the source of truth for runtime secrets. The deployment role expects:

- a runtime `VAULT_TOKEN`
- pre-existing values at `secret/data/medical-chatbot` for:
  - `ml_service_url`
  - `backend_shared_secret`

Backend secret/config status endpoint:

```text
GET /api/status
```

This confirms configuration presence without revealing secret values.

## Documentation

Submission/report artifacts were generated locally and are intentionally ignored by Git:

- `FINAL_PROJECT_REPORT.md`
- `FINAL_PROJECT_REPORT.tex`
- `FINAL_PROJECT_REPORT.pdf`
- `report-assets/`

## Next Improvements

Recommended future work:

- make Kubernetes the default production deploy target
- tighten Trivy policy to fail on critical findings
- add richer Kibana dashboards and alerts
- add notification hooks for failed pipelines or failed deploy verification
- validate Kubernetes-to-ELK log flow end-to-end in the active environment
