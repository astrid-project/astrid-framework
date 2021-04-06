# Variables for master version

Name                    | Default value         | Meaning
------------------------|-----------------------|--------
LCP_HOST                | 0.0.0.0               | IP address to accept requests.
LCP_PORT                | 5000                  | TCP port to accept requests.
LCP_HTTPS               | false                 | Accept only HTTPS requests.
LCP_AUTH_ENABLED        | true                  | Enable JWT authentication.
LCP_AUTH_HEADER_PREFIX  | ASTRID                | Header prefix for JWT authentication.
LCP_AUTH_SECRET_KEY     | astrid-secret-key     | Secret key for JWT authentication.
LCP_ELASTIC_APM_ENABLED | false                 | Enable [Elastic APM](https://www.elastic.co/apm) integration.
LCP_ELASTIC_APM_SERVER  | http://localhost:8200 | Elastic APM server.
LCP_POLYCUBE_HOST       | localhost             | IP address to contact the [Polycube](https://github.com/polycube-network/polycube) installation.
LCP_POLYCUBE_PORT       | 9000                  | Port address to contact the Polycube installation.
LCP_POLYCUBE_TIMEOUT    | 20s                   | Timeout for the connection to Polycube.
LCP_LOG_CONFIG          | log.yaml              | Log configuration path.
