# Metricbeat

## Contents

- [Metricbeat](#metricbeat)
  - [Contents](#contents)
  - [Installation Steps](#installation-steps)
    - [Setup](#setup)
    - [Initialization](#initialization)
    - [Configuration](#configuration)
    - [Start](#start)
    - [Stop](#stop)
  - [Health](#health)

## Installation Steps

### Setup

The variables are defined in [scripts/vars](scripts/vars).

Name                | Default value                        | Meaning
--------------------|--------------------------------------|--------
VERSION             | 7.8.0                                | Version number
COMPONENT           | metricbeat                           | Component name
INSTALLATION_PATH   | /opt/`COMPONENT`                     | Directory path where the software will be installed
MODULES_PATH        | `$INSTALLATION_PATH`/modules.d       | Directory path where the module configurations will be stored
TMP_PATH            | /tmp                                 | Temporary dictionary path
SOURCE              | `$COMPONENT`-`$VERSION`-linux-x86_64 | Source filename
FILE                | `$SOURCE`.tar.gz                     | Source archive
PIDFILE             | `$TMP_PATH`/`$COMPONENT`.pid         | File path where the PID of the current execution is stored
MONITORING_ENABLED  | false                                | Enable monitoring with Elasticsearch
ELASTICSEARCH_HOSTS | localhost:9200                       | Elasticsearch endpoints to connect for monitoring
LOGSTASH_HOSTS      | localhost:5044                       | Logstash endpoints where to send the collected data

### Initialization

```console
$ scrips/init
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

## Health

Check if the software is running or not.

```console
$ scripts/health
```
