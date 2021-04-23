# Logstash

[![Docker image](https://img.shields.io/docker/image-size/astridproject/logstash-local?label=image&logo=docker)](https://hub.docker.com/repository/docker/astridproject/logstash-local)

## Contents

- [Logstash](#logstash)
  - [Contents](#contents)
  - [Installation Steps](#installation-steps)
    - [Setup](#setup)
    - [Requirements](#requirements)
    - [Initialization](#initialization)
    - [Start](#start)
    - [Stop](#stop)
    - [Health](#health)
  - [Docker image](#docker-image)

## Installation Steps

### Setup

The variables are defined in [scripts/vars](scripts/vars).

Name                             | Default value                | Meaning
---------------------------------|------------------------------|--------
COMPONENT                        | logstash                     | Component name
VERSION                          | 7.8.0                        | Version number
INSTALLATION_PATH                | /opt/`COMPONENT`             | Directory path where the software will be installed
TMP_PATH                         | /tmp                         | Temporary dictionary path
SOURCE                           | `$COMPONENT`-`$VERSION`      | Source filename
FILE                             | `$SOURCE`.zip                | Source archive
PIDFILE                          | `$TMP_PATH`/`$COMPONENT`.pid | File path where the PID of the current execution is stored
LOGSTASH_PORT                    | 5044                         | Port where Logstash is listening to get the data from the beats
ELASTICSEARCH_HOSTS              | localhost:9200               | Elasticsearch endpoints to connect for monitoring
ELASTICSEARCH_MONITORING_ENABLED | false                        | Enable monitoring with Elasticsearch
KAFKA_BOOTSTRAP_SERVERS          | localhost:9092               | Kafka endpoints where to send the data

### Requirements

Enter into the `scripts` directory.

```console
$ cd scripts
```

### Initialization

```console
$ bash ./init.sh
```

### Start

```console
$ bash ./start.sh
```

### Stop

```console
$ bash ./stop.sh
```

### Health

Check if the software is running or not.

```console
$ bash ./health.sh
```

## Docker image

[Dockerfile](Dockerfile) is used to build the `docker` image with CI in the [https://hub.docker.com/repository/docker/astridproject/logstash-local](https://hub.docker.com/repository/docker/astridproject/logstash-local).
