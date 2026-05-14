FROM docker.elastic.co/logstash/logstash:8.14.3

RUN /usr/share/logstash/bin/logstash-plugin install logstash-input-gelf

COPY pipeline/logstash.conf /usr/share/logstash/pipeline/logstash.conf
