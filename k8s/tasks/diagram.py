#!/usr/bin/env inv
# Copyright (c) 2020 ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

# cspell:ignore strg srvs

from diagrams import Cluster, Diagram
from diagrams.elastic.elasticsearch import Elasticsearch, Logstash
from diagrams.k8s.compute import Deployment, Pod, ReplicaSet
from diagrams.k8s.group import NS
from diagrams.k8s.infra import Master, Node
from diagrams.k8s.network import Ingress, Service
from diagrams.k8s.podconfig import CM
from diagrams.k8s.storage import PV, PVC
from diagrams.onprem.network import Zookeeper
from diagrams.onprem.queue import Kafka
from diagrams.programming.language import Python
from invoke import task


@task
def general(c):
    with Diagram('general', show=False):
        _ = NS('astrid-kube')
        _cb_pod = Pod('CB')
        _cb_deploy = Deployment('CB')

        with Cluster('Services'):
            _srvs = [Service('elasticsearch-service'),
                         Service('kafka-service'), Service('cb-manager-service')]

        with Cluster('Storage'):
            _strg = PVC('elasticsearch-pv-volume') >> PV('elasticsearch-pv')

        _srvs >> _cb_pod << _cb_deploy << _strg


@task
def cb(c):
    with Diagram('cb', show=False):
        _kafka = Kafka('Kafka')
        _zk = Zookeeper('Zookeeper')
        _logstash = Logstash('Logstash')
        _elasticsearch = Elasticsearch('Elasticsearch')
        _cb_man = Python('cb-manager')

        with Cluster('elasticsearch-config'):
            _elasticsearch_cfg = [CM('elasticsearch.yml'), CM('log4j2.properties')]
        _ = _elasticsearch_cfg - _elasticsearch

        with Cluster('logstash-config'):
            _logstash_cfg = [CM('logstash.yml'), CM('log4j2.properties')]
        _ = _logstash_cfg - _logstash

        with Cluster('logstash-pipeline'):
            _logstash_pipe = [CM('data.conf')]
        _ = _logstash_pipe - _logstash

        _zk - _kafka >> _logstash >> _elasticsearch << _cb_man
        _logstash << _cb_man >> _kafka


@task
def infrastructure(c):
    with Diagram('infrastructure', show=False):
        _ = Master('compute01') - Node('compute02') - Node('compute03')
