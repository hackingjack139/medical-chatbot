# Vault Setup

This project uses HashiCorp Vault in Docker dev mode for coursework demonstration.

Vault endpoint:

```text
http://localhost:8200
```

The Ansible deployment role:

1. Starts Vault
2. Reads deployment secrets from Vault
3. Generates the application `.env` file from Vault values

When this deploy flow runs inside Jenkins, Vault is reached at:

```text
http://host.docker.internal:8200
```

because Jenkins itself runs in a container while the Vault container is started on the host Docker daemon.

Demo note:

- This is a local development/demo Vault setup, not production-hardening.
- Vault is treated as the source of truth for deployment secrets.
- The deploy flow expects these keys at `secret/data/medical-chatbot`:
  - `ml_service_url`
  - `backend_shared_secret`
- The deployment also expects a runtime `VAULT_TOKEN`.

Example secret seeding for local use:

```bash
export VAULT_TOKEN=your-token
vault kv put secret/medical-chatbot \
  ml_service_url="http://ml-model:8000/predict" \
  backend_shared_secret="your-shared-secret"
```
