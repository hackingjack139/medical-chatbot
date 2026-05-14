# ELK Observability

Start ELK stack:

```bash
docker compose -f observability/docker-compose.elk.yml up -d --build
```

Open:

- Elasticsearch: `http://localhost:9200`
- Kibana: `http://localhost:5601`

Application containers in `docker-compose.deploy.yml` use Docker's `gelf` logging driver and forward logs to Logstash on `udp://host.docker.internal:12201`.

Suggested Kibana data view:

```text
medical-chatbot-logs-*
```
