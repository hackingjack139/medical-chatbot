# Vault Setup

This project uses HashiCorp Vault in Docker dev mode for coursework demonstration.

Vault endpoint:

```text
http://localhost:8200
```

The Ansible deployment role:

1. Starts Vault
2. Writes deployment secrets into Vault
3. Reads them back
4. Generates the application `.env` file from Vault values

Demo note:

- This is a local development/demo Vault setup, not production-hardening.
