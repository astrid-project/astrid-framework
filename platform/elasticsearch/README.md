# Elasticsearch

[![Docker image](https://img.shields.io/docker/image-size/astridproject/elasticsearch?label=image&logo=docker)](https://hub.docker.com/repository/docker/astridproject/elasticsearch)

## Contents

- [Elasticsearch](#elasticsearch)
  - [Contents](#contents)
  - [Installation Steps](#installation-steps)
    - [Setup](#setup)
    - [Initialization](#initialization)
    - [Configuration](#configuration)
    - [Start](#start)
    - [Stop](#stop)
    - [Health](#health)
  - [Docker image](#docker-image)

## Installation Steps

### Setup

The variables are defined in [scripts/vars](scripts/vars).

Name                             | Default value                | Meaning
---------------------------------|------------------------------|--------
COMPONENT                        | elasticsearch                | Component name
VERSION                          | 7.8.0                        | Version number
INSTALLATION_PATH                | /opt/`COMPONENT`             | Directory path where the software will be installed
TMP_PATH                         | /tmp                         | Temporary dictionary path
SOURCE                           | `$COMPONENT`-`$VERSION`      | Source filename
FILE                             | `$SOURCE`.zip                | Source archive
PIDFILE                          | `$TMP_PATH`/`$COMPONENT`.pid | File path where the PID of the current execution is stored
ELASTICSEARCH_PORT               | 9200                         | Port where Elasticsearch listen to get the data
ELASTICSEARCH_MONITORING_ENABLED | false                        | Enable monitoring
ELASTICSEARCH_TRANSPORT_TCP_PORT | localhost:9092               | Port for communications between nodes in a Elasticsearch cluster

### Initialization

```console
$ scripts/init
```

### Configuration

Before to run the software, it could be necessary to update the configuration files located in [settings](settings) directory.

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

[Dockerfile](Dockerfile) is used to build the `docker` image with CI in the [https://hub.docker.com/repository/docker/astridproject/elasticsearch](https://hub.docker.com/repository/docker/astridproject/elasticsearch).
