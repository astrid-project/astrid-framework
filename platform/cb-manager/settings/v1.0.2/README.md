# Variables for v1.0.2 version

Name                                | Default value                                                         | Meaning
------------------------------------|-----------------------------------------------------------------------|--------
CB_MAN_HOST                         | 0.0.0.0                                                               | IP address to accept requests.
CB_MAN_PORT                         | 5000                                                                  | TCP port to accept requests.
CB_MAN_HEARTBEAT_TIMEOUT            | 10s                                                                   | Timeout for heartbeat procedure with LCPs.
CB_MAN_HEARTBEAT_PERIOD             | 1min                                                                  | Period to execute the heartbeat procedure with LCPs.
CB_MAN_HEARTBEAT_AUTH_EXPIRATION    | 5min                                                                  | Period for auth expiration in the heartbeat procedure with LCPs.
CB_MAN_ELASTICSEARCH_ENDPOINT       | localhost:9200                                                        | Endpoint connection to Elasticsearch instance.
CB_MAN_ELASTICSEARCH_TIMEOUT        | 20s                                                                   | Timeout for connection to Elasticsearch instance.
CB_MAN_ELASTICSEARCH_RETRY_PERIOD   | 1min                                                                  | Time to wait to retry the connection to Elasticsearch instance.
CB_MAN_ELASTIC_APM_SERVER           | http://localhost:8200                                                 | [Elastic APM](https://www.elastic.co/apm) server.
CB_MAN_DEV_USERNAME                 | cb-manager                                                            | Authorized username for development.
CB_MAN_DEV_PASSWORD                 | 9c804f2550e31d8f98ac9b460cfe7fbfc676c5e4452a261a2899a1ea168c0a50 [^1] | Authorized password for development.
CB_MAN_LOG_LEVEL                    | DEBUG                                                                 | Log level.

## References

[^1]: Password: "astrid" hashed in sha256
