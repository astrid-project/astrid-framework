# Variables for v1.0.3 version

Name                    | Default value                                                         | Meaning
------------------------|-----------------------------------------------------------------------|--------
LCP_HOST                | 0.0.0.0                                                               | IP address to accept requests.
LCP_PORT                | 5000                                                                  | TCP port to accept requests.
LCP_AUTH_MAX_TTL        | 10min                                                                 | Max TTL [^1] for authentication.
LCP_POLYCUBE_HOST       | localhost                                                             | IP address to contact the [Polycube](https://github.com/polycube-network/polycube) installation.
LCP_POLYCUBE_PORT       | 9000                                                                  | Port address to contact the Polycube installation.
LCP_POLYCUBE_TIMEOUT    | 20s                                                                   | Timeout for the connection to Polycube.
LCP_DEV_USERNAME        | lcp                                                                   | Authorized username for development.
LCP_DEV_PASSWORD        | 9c804f2550e31d8f98ac9b460cfe7fbfc676c5e4452a261a2899a1ea168c0a50 [^2] | Authorized password for development.
LCP_LOG_LEVEL           | DEBUG                                                                 | Log level.

## References

[^1]: Time To Live.

[^2]: Password: "astrid" hashed in sha256.
