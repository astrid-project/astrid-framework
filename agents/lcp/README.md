# LCP (Local Control Policies)

[![License](https://img.shields.io/github/license/astrid-project/lcp)](https://github.com/astrid-project/lcp/blob/master/LICENSE)
[![Code size](https://img.shields.io/github/languages/code-size/astrid-project/lcp?color=red&logo=github)](https://github.com/astrid-project/lcp)
[![Repository Size](https://img.shields.io/github/repo-size/astrid-project/lcp?color=red&logo=github)](https://github.com/astrid-project/lcp)
[![Release](https://img.shields.io/github/v/tag/astrid-project/lcp?label=release&logo=github)](https://github.com/astrid-project/lcp/releases)
[![Docker image](https://img.shields.io/docker/image-size/astridproject/lcp?label=image&logo=docker)](https://hub.docker.com/repository/docker/astridproject/lcp)
[![Docs](https://readthedocs.org/projects/astrid-lcp/badge/?version=latest)](https://astrid-lcp.readthedocs.io)

## Contents

- [LCP (Local Control Policies)](#lcp-local-control-policies)
  - [Contents](#contents)
  - [Installation Steps](#installation-steps)
    - [Setup](#setup)
    - [Requirements](#requirements)
    - [Initialization](#initialization)
    - [Start](#start)
    - [Stop](#stop)
    - [Health](#health)
  - [Docker image](#docker-image)
  - [References](#references)

The source code is available in the [src](github.com/astrid-project/lcp) directory as git sub-module.

## Installation Steps

### Setup

The variables are defined in [scripts/vars](scripts/vars).

Name                 | Default value                                                         | Meaning
---------------------|-----------------------------------------------------------------------|--------
COMPONENT            | lcp                                                                   | Component name
VERSION              | master                                                                | Component version
PROJECT              | astrid                                                                | Project name
INSTALLATION_PATH    | /opt/lcp                                                              | Destination path where the software will be installed
TMP_PATH             | /tmp                                                                  | Temporary dictionary path
PIDFILE              | `$TMP`/`$COMPONENT`.pid                                               | File path where the PID of the current execution is stored
LCP_HOST             | 0.0.0.0                                                               | Host address where LCP is listening
LCP_PORT             | 4000                                                                  | TCP port where LCP is listening
LCP_AUTH_MAX_TTL     | 10min                                                                 | Maximum time for HTTP authorization validity
LCP_POLYCUBE_HOST    | 127.0.0.1                                                             | Polycube host address
LCP_POLYCUBE_PORT    | 9000                                                                  | Polycube port address
LCP_POLYCUBE_TIMEOUT | 20s                                                                   | Timeout for requests to Polycube
LCP_DEV_USERNAME     | lcp                                                                   | Username for HTTP authorization (used in development)
LCP_DEV_PASSWORD     | 9c804f2550e31d8f98ac9b460cfe7fbfc676c5e4452a261a2899a1ea168c0a50 [^1] | Password for HTTP authorization (used in development)
LCP_LOG_LEVEL        | DEBUG                                                                 | General LOG level

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

[Dockerfile](Dockerfile) is used to build the `docker` image with CI in the [https://hub.docker.com/repository/docker/astridproject/lcp](https://hub.docker.com/repository/docker/astridproject/lcp).

## References

[^1] Password: "astrid" hashed in sha256.
