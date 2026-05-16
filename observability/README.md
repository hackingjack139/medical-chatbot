# ELK Observability

Start ELK stack:

```bash
docker compose -f observability/docker-compose.elk.yml up -d
```

Open:

- Elasticsearch: `http://localhost:9200`
- Kibana: `http://localhost:5601`

Current ingestion paths:

1. Docker Compose application containers
   - use Docker `gelf` logging
   - forward to Logstash on `udp://127.0.0.1:12201`

2. Kubernetes application pods
   - use Fluent Bit as a DaemonSet
   - forward to Logstash on `tcp://host.docker.internal:24224`

Suggested Kibana data view:

```text
medical-chatbot-logs-*
```

Useful fields:

- `app`
- `log_source`
- `container_name`
- `kubernetes.container_name`

Typical `log_source` values:

- `docker-compose`
- `kubernetes`
