#!/usr/bin/env inv
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

# cspell:ignore strg srvs

from diagrams import Cluster, Diagram
from diagrams.elastic.elasticsearch import (Beats, Elasticsearch, Kibana,
                                            Logstash)
from diagrams.generic.blank import Blank
from diagrams.k8s.compute import Deployment, Pod
from diagrams.k8s.group import NS
from diagrams.k8s.network import Service
from diagrams.k8s.podconfig import CM
from diagrams.k8s.storage import PV, PVC
from diagrams.onprem.database import MySQL
from diagrams.onprem.network import Apache, Zookeeper
from diagrams.onprem.queue import Kafka
from invoke import task


@task
def general(c):
    with Diagram('Context', filename='general', show=False, graph_attr={'pad': '0.0'}):
        _ = NS('astrid-kube')
        _cb_pod = Pod('CB')
        _cb_deploy = Deployment('CB')

        with Cluster('Services'):
            _srvs = [Service('elasticsearch-service'),
                     Service('kafka-service'), Service('cb-manager-service'), Service('kibana')]

        with Cluster('Storage'):
            _strg = PVC('elasticsearch-pv-volume') >> PV('elasticsearch-pv')

        _srvs >> _cb_pod << _cb_deploy << _strg


@task
def cb(c, version):
    with Diagram(f'Context Broker (ver. {version}) Pod', filename=f'cb-{version}', show=False, graph_attr={'pad': '0.0'}):
        _metricbeat = Beats('Metricbeat')
        _heartbeat = Beats('Heartbeat')
        _kafka = Kafka('Kafka')
        _zk = Zookeeper('Zookeeper')
        _logstash = Logstash('Logstash')
        _elasticsearch = Elasticsearch('Elasticsearch')
        _kibana = Kibana('Kibana')

        with Cluster('elasticsearch-config'):
            _elasticsearch_cfg = [CM(f'elasticsearch-{version}.yml'), CM('log4j2.properties')]
        _ = _elasticsearch_cfg - _elasticsearch

        with Cluster('heartbeat-config'):
            _heartbeat_cfg = [CM('hearbeat.yml')]
        _ = _heartbeat_cfg - _heartbeat

        with Cluster('heartbeat-monitor'):
            _heartbeat_monitor = [CM('elasticsearch.yml'), CM('host.yml'), CM('kafka.yml'),
                                  CM('kibana.yml'), CM('logstash.yml'), CM('zookeeper.yml')]
        _ = _heartbeat_monitor - _heartbeat

        with Cluster('kibana-config'):
            _kibana_cfg = [CM('kibana.yml')]
        _ = _kibana_cfg - _kibana

        with Cluster('logstash-config'):
            _logstash_cfg = [CM('logstash.yml'), CM('pipelines.yml'), CM('log4j2.properties')]
        _ = _logstash_cfg - _logstash

        with Cluster('logstash-pipeline'):
            _logstash_pipe = [CM('apache.conf'), CM('mysql.conf'), CM('ssh-server.conf'), CM('system.conf')]
        _ = _logstash_pipe - _logstash

        with Cluster('metricbeat-config'):
            _metricbeat_cfg = [CM('metricbeat.yml')]
        _ = _metricbeat_cfg - _metricbeat

        with Cluster('metricbeat-modules'):
            _metricbeat_mod = [CM('kafka.yml')]
        _ = _metricbeat_mod - _metricbeat

        _zk - _kafka >> _logstash >> _elasticsearch
        _elasticsearch << _kibana
        _logstash << _metricbeat
        _logstash << _heartbeat


@task
def apache(c):
    with Diagram('Apache HTTP Server Pod', filename='apache', show=False, graph_attr={'pad': '0.0'}):
        _apache = Apache('Apache HTTP Server')
        _filebeat = Beats('Filebeat')
        _metricbeat = Beats('Metricbeat')
        _heartbeat = Beats('Heartbeat')
        _logstash = Logstash('Logstash')

        with Cluster('apache-config'):
            _apache_cfg = [CM('http.conf')]
        _ = _apache_cfg - _apache

        with Cluster('filebeat'):
            _filebeat_file = [CM('filebeat.yml')]
        _ = _filebeat_file - _filebeat

        with Cluster('filebeat-config'):
            _filebeat_cfg = [CM('log.yml')]
        _ = _filebeat_cfg - _filebeat

        with Cluster('heartbeat-config'):
            _heartbeat_cfg = [CM('hearbeat.yml')]
        _ = _heartbeat_cfg - _heartbeat

        with Cluster('heartbeat-monitor'):
            _heartbeat_monitor = [CM('host.yml'), CM('logstash.yml'), CM('server.yml')]
        _ = _heartbeat_monitor - _heartbeat

        with Cluster('logstash-config'):
            _logstash_cfg = [CM('logstash.yml'), CM('pipelines.yml'), CM('log4j2.properties')]
        _ = _logstash_cfg - _logstash

        with Cluster('logstash-pipeline'):
            _logstash_pipe = [CM('apache.conf'), CM('system.conf')]
        _ = _logstash_pipe - _logstash

        with Cluster('metricbeat-config'):
            _metricbeat_cfg = [CM('metricbeat.yml')]
        _ = _metricbeat_cfg - _metricbeat

        with Cluster('metricbeat-modules'):
            _metricbeat_mod = [CM('system.yml')]
        _ = _metricbeat_mod - _metricbeat

        _apache >> _filebeat >> _logstash
        _logstash << _metricbeat
        _logstash << _heartbeat


@task
def mysql(c, version):
    with Diagram(f'MySQL Server (ver. {version}) Pod', filename=f'mysql-{version}', show=False, graph_attr={'pad': '0.0'}):
        _mysql = MySQL('MySQL Server')
        _metricbeat = Beats('Metricbeat')
        _heartbeat = Beats('Heartbeat')
        _logstash = Logstash('Logstash')

        with Cluster('heartbeat-config'):
            _heartbeat_cfg = [CM('hearbeat.yml')]
        _ = _heartbeat_cfg - _heartbeat

        with Cluster('heartbeat-monitor'):
            _heartbeat_monitor = [CM('host.yml'), CM('logstash.yml'), CM('server.yml')]
        _ = _heartbeat_monitor - _heartbeat

        with Cluster('logstash-config'):
            _logstash_cfg = [CM('logstash.yml'), CM('pipelines.yml'), CM('log4j2.properties')]
        _ = _logstash_cfg - _logstash

        with Cluster('logstash-pipeline'):
            _logstash_pipe = [CM(f'mysql-system-{version}.conf')]
        _ = _logstash_pipe - _logstash

        with Cluster('metricbeat-config'):
            _metricbeat_cfg = [CM('metricbeat.yml')]
        _ = _metricbeat_cfg - _metricbeat

        with Cluster('metricbeat-modules'):
            _metricbeat_mod = [CM('system.yml')]
        _ = _metricbeat_mod - _metricbeat

        _mysql >> _metricbeat >> _logstash
        _logstash << _heartbeat


@task
def ssh_server(c):
    with Diagram('SSH Server Pod', filename='ssh_server', show=False, graph_attr={'pad': '0.0'}):
        _ssh_server = Blank('OpenSSH Server')
        _polycube = Blank('Polycube')
        _cubebeat = Beats('Cubebeat')
        _metricbeat = Blank('Metricbeat')
        _heartbeat = Beats('Heartbeat')
        _logstash = Logstash('Logstash')

        with Cluster('cubebeat'):
            _cubebeat_file = [CM('cubebeat.yml')]
        _ = _cubebeat_file - _cubebeat

        with Cluster('cubebeat-config'):
            _cubebeat_cfg = [CM('synflood.yml')]
        _ = _cubebeat_cfg - _cubebeat

        with Cluster('heartbeat-config'):
            _heartbeat_cfg = [CM('hearbeat.yml')]
        _ = _heartbeat_cfg - _heartbeat

        with Cluster('heartbeat-monitor'):
            _heartbeat_monitor = [CM('host.yml'), CM('logstash.yml'), CM('server.yml')]
        _ = _heartbeat_monitor - _heartbeat

        with Cluster('logstash-config'):
            _logstash_cfg = [CM('logstash.yml'), CM('pipelines.yml'), CM('log4j2.properties')]
        _ = _logstash_cfg - _logstash

        with Cluster('logstash-pipeline'):
            _logstash_pipe = [CM('ssh-server.conf'), CM('system.conf')]
        _ = _logstash_pipe - _logstash

        with Cluster('metricbeat-config'):
            _metricbeat_cfg = [CM('metricbeat.yml')]
        _ = _metricbeat_cfg - _metricbeat

        with Cluster('metricbeat-modules'):
            _metricbeat_mod = [CM('system.yml')]
        _ = _metricbeat_mod - _metricbeat

        _ssh_server >> _polycube >> _cubebeat >> _logstash
        _logstash << _metricbeat
        _logstash << _heartbeat
