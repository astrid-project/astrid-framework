# CB-Manager (Context Broker Manager)

## Contents

- [CB-Manager (Context Broker Manager)](#cb-manager-context-broker-manager)
  - [Contents](#contents)
  - [Installation Steps](#installation-steps)
    - [Setup](#setup)
    - [Initialization](#initialization)
    - [Configuration](#configuration)
    - [Start](#start)
    - [Stop](#stop)
  - [Health](#health)
  - [References](#references)

The source code is available in the [src](github.com/astrid-project/cb-manager) directory as git sub-module.

## Installation Steps

### Setup

The variables are defined in [scripts/vars](scripts/vars).

Name                              | Default value                                                         | Meaning
----------------------------------|-----------------------------------------------------------------------|--------
COMPONENT                         | cb-manager                                                            | Component name
INSTALLATION_PATH                 | /opt/`$COMPONENT`                                                     | Destination path where the software will be installed
TMP_PATH                          | /tmp                                                                  | Temporary dictionary path
PIDFILE                           | `$TMP`/`$COMPONENT`.pid                                               | File path where the PID of the current execution is stored
CB_MAN_HOST                       | 0.0.0.0                                                               | Host address where CB-Manager is listening
CB_MAN_PORT                       | 5000                                                                  | TCP port where CB-Manager is listening
CB_MAN_HEARTBEAT_PERIOD           | 1min                                                                  | Heartbeat period
CB_MAN_HEARTBEAT_TIMEOUT          | 20s                                                                   | Heartbeat timeout
CB_MAN_HEARTBEAT_AUTH_EXPIRATION  | 5min                                                                  | Heartbeat authentication time validity
CB_MAN_ELASTICSEARCH_ENDPOINT     | localhost:9200                                                        | Elasticsearch endpoint
CB_MAN_ELASTICSEARCH_TIMEOUT      | 20s                                                                   | Timeout for requests to Elasticsearch
CB_MAN_ELASTICSEARCH_RETRY_PERIOD | 1min                                                                  | Period of time to wait after which to retry connection with Elasticsearch
CB_MAN_DEV_USERNAME               | cb-manager                                                            | Username for HTTP authorization (used in development)
CB_MAN_DEV_PASSWORD               | 9c804f2550e31d8f98ac9b460cfe7fbfc676c5e4452a261a2899a1ea168c0a50 [^1] | Password for HTTP authorization (used in development)
CB_MAN_LOG_LEVEL                  | DEBUG                                                                 | General LOG level

### Initialization

```console
$ scripts/init
```

### Configuration

Before to run the software, it could be necessary to update the configuration file in [settings](settings) directory.

### Start

```console
$ scripts/start
```

### Stop

```console
$ scripts/stop
```

## Health

Check if the software is running or not.

```console
$ scripts/health
```

## References

[^1] Password: "astrid" hashed in sha256.
