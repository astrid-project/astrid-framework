# Kafka

[![Docker image](https://img.shields.io/docker/image-size/astridproject/kafka?label=image&logo=docker)](https://hub.docker.com/repository/docker/astridproject/kafka)

## Contents

- [Kafka](#kafka)
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

Name                    | Default value                            | Meaning
------------------------|------------------------------------------|--------
VERSION                 | 2.6.0                                    | Version number
SCALA_VERSION           | 2.12.0                                   | Version of `Scala` programming language
COMPONENT               | kafka                                    | Component name
INSTALLATION_PATH       | /opt/`$COMPONENT`                        | Directory path where the software will be installed
TMP_PATH                | /tmp                                     | Temporary dictionary path
SOURCE                  | `$COMPONENT`_`$SCALA_VERSION`-`$VERSION` | Source filename
FILE                    | `$SOURCE`.tgz                            | Source archive
PIDFILE                 | `$TMP_PATH`/`$COMPONENT`.pid             | File path where the PID of the current execution is stored

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

[Dockerfile](Dockerfile) is used to build the `docker` image with CI in the [https://hub.docker.com/repository/docker/astridproject/kafka](https://hub.docker.com/repository/docker/astridproject/kafka).
