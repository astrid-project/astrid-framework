# CB-Manager (Context Broker Manager)

[![License](https://img.shields.io/github/license/astrid-project/cb-manager)](https://github.com/astrid-project/cb-manager/blob/master/LICENSE)
[![Code size](https://img.shields.io/github/languages/code-size/astrid-project/cb-manager?color=red&logo=github)](https://github.com/astrid-project/cb-manager)
[![Repository Size](https://img.shields.io/github/repo-size/astrid-project/cb-manager?color=red&logo=github)](https://github.com/astrid-project/cb-manager)
[![Release](https://img.shields.io/github/v/tag/astrid-project/cb-manager?label=release&logo=github)](https://github.com/astrid-project/cb-manager/releases)
[![Docker image](https://img.shields.io/docker/image-size/astridproject/cb-manager?label=image&logo=docker)](https://hub.docker.com/repository/docker/astridproject/cb-manager)
[![Docs](https://readthedocs.org/projects/astrid-cb-manager/badge/?version=latest)](https://astrid-cb-manager.readthedocs.io)

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
  - [Docker image](#docker-image)
  - [References](#references)

The source code is available in the [src](github.com/astrid-project/cb-manager) directory as git sub-module.

## Installation Steps

### Setup

The variables are defined in [scripts/vars](scripts/vars).

Name                              | Default value                                                         | Meaning
----------------------------------|-----------------------------------------------------------------------|--------
COMPONENT                         | cb-manager                                                            | Component name
VERSION                           | master                                                                | Component version
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

### Health

Check if the software is running or not.

```console
$ scripts/health
```

## Docker image

[Dockerfile](Dockerfile) is used to build the `docker` image with CI in the [https://hub.docker.com/repository/docker/astridproject/cb-manager](https://hub.docker.com/repository/docker/astridproject/cb-manager).

## References

[^1] Password: "astrid" hashed in sha256.
