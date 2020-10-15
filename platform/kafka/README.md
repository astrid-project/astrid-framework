# Kafka

[![Docker image](https://img.shields.io/docker/image-size/astridproject/kafka?label=image&logo=docker)](https://hub.docker.com/repository/docker/astridproject/kafka)

## Contents

- [Kafka](#kafka)
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

Name                    | Default value                            | Meaning
------------------------|------------------------------------------|--------
COMPONENT               | kafka                                    | Component name
COMPONENT_DEP           | zookeeper                                | Component dependency name
VERSION                 | 2.6.0                                    | Version number
SCALA_VERSION           | 2.12.0                                   | Version of `Scala` programming language
INSTALLATION_PATH       | /opt/`$COMPONENT`                        | Directory path where the software will be installed
TMP_PATH                | /tmp                                     | Temporary dictionary path
SOURCE                  | `$COMPONENT`_`$SCALA_VERSION`-`$VERSION` | Source filename
FILE                    | `$SOURCE`.tgz                            | Source archive
PIDFILE                 | `$TMP_PATH`/`$COMPONENT`.pid             | File path where the PID of the current execution is stored
PIDFILE_DEP             | `$TMP_PATH`/`$COMPONENT_DEP`.pid         | File path where the PID of the current execution dependency is stored
ZOOKEEPER_PORT          | 2181                                     | Port at which the clients will connect.
KAFKA_PORT              | 9092                                     | The port the socket server listens on.

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

[Dockerfile](Dockerfile) is used to build the `docker` image with CI in the [https://hub.docker.com/repository/docker/astridproject/kafka](https://hub.docker.com/repository/docker/astridproject/kafka).
