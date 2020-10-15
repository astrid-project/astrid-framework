# Logstash

[![Docker image](https://img.shields.io/docker/image-size/astridproject/logstash-central?label=image&logo=docker)](https://hub.docker.com/repository/docker/astridproject/logstash-central)

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
ELASTICSEARCH_HOSTS              | localhost:9200               | Elasticsearch endpoints to connect for monitoring and to send the data get from Kafka
ELASTICSEARCH_MONITORING_ENABLED | false                        | Enable monitoring with Elasticsearch
KAFKA_BOOTSTRAP_SERVERS          | localhost:9092               | Kafka endpoints where to get the data

### Requirements

Enter into the `scripts` directory.

```console
$ cd scripts
```

### Initialization

```console
$ ./init
```

### Start

```console
$ ./start
```

### Stop

```console
$ ./stop
```

### Health

Check if the software is running or not.

```console
$ ./health
```

## Docker image

[Dockerfile](Dockerfile) is used to build the `docker` image with CI in the [https://hub.docker.com/repository/docker/astridproject/logstash-central](https://hub.docker.com/repository/docker/astridproject/logstash-central).
