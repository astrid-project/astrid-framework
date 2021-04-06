# Variables for master version

Name                                | Default value         | Meaning
------------------------------------|-----------------------|--------
CB_MAN_HOST                         | 0.0.0.0               | IP address to accept requests.
CB_MAN_PORT                         | 5000                  | TCP port to accept requests.
CB_MAN_HTTPS                        | false                 | Accept only HTTPS requests.
CB_MAN_AUTH_ENABLED                 | true                  | Enable JWT authentication.
CB_MAN_AUTH_HEADER_PREFIX           | ASTRID                | Header prefix for JWT authentication.
CB_MAN_AUTH_SECRET_KEY              | astrid-secret-key     | Secret key for JWT authentication.
CB_MAN_HEARTBEAT_TIMEOUT            | 10s                   | Timeout for heartbeat procedure with LCPs.
CB_MAN_HEARTBEAT_PERIOD             | 1min                  | Period to execute the heartbeat procedure with LCPs.
CB_MAN_ELASTICSEARCH_ENDPOINT       | localhost:9200        | Endpoint connection to Elasticsearch instance.
CB_MAN_ELASTICSEARCH_TIMEOUT        | 20s                   | Timeout for connection to Elasticsearch instance.
CB_MAN_ELASTICSEARCH_RETRY_PERIOD   | 1min                  | Time to wait to retry the connection to Elasticsearch instance.
CB_MAN_ELASTIC_APM_ENABLED          | false                 | Enable [Elastic APM](https://www.elastic.co/apm) integration.
CB_MAN_ELASTIC_APM_SERVER           | http://localhost:8200 | Elastic APM server.
CB_MAN_CONFIG                       | log.yaml              | Log configuration path.
