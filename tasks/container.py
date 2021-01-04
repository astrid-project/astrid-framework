#!/usr/bin/env inv
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

from config import config
from docker import from_env
from invoke import task
from log import logger
from screenutils import Screen
from telegrot import telegrot
from utils import StdClass

log = logger('container')
cfg = config('project', 'icon')

client = from_env()


@task
def attach(c, component=None, version=None, stdout=True, stderr=True, stream=True, logs=False):
    __check_all(component, version)
    _cnt = __cnt(component, version)

    def __call():
        _cnt.attach(stdout=stdout, stderr=stderr, stream=stream, logs=logs)
    if stream:
        for _output in __call():
            yield log.info(_output, line=True)
    else:
        log.info(__call())


@task
def build(c, component=None, version=None, path=None, nocache=True, rm=True, network_mode='bridge'):
    __check_all(component, version, path=path)
    client.images.build(path=path, nocache=nocache, rm=rm, network_mode=network_mode,
                        buildargs=dict(VERSION=version), tag=__tag(component, version))


@task
def dev(c, component=None, version=None):
    _cnt = __cnt(component, version)
    _oh_my_bash = 'https://raw.githubusercontent.com/alexcarrega/oh-my-bash/master/tools/install.sh'
    _cnt.exec_run('apk add git bash')
    _cnt.exec_run(f'sh -c "$(wget {_oh_my_bash} -O -)"')


@task
def logs(c, component=None, version=None, stdout=True, stderr=True,
         stream=True, timestamps=True, tail='all'):
    _cnt = __cnt(component, version)

    def __call():
        _cnt.logs(stdout=stdout, stderr=stderr, stream=stream,
                  timestamps=timestamps, tail=tail)
    if stream:
        for _output in __call():
            yield log.info(_output, line=True)
    else:
        log.info(__call())


@task
def pause(c, component=None, version=None):
    _cnt = __cnt(component, version)
    _c_cmpt, _c_vrs = f'[hl]{component}[/hl]', f'[hl]{version}[/hl]'
    _h_cmpt, _h_vrs = f'<b>{component}</b>', f'<b>{version}</b>'
    try:
        _cnt.pause()
        msg = f'Component %s with version %s paused correctly'
        log.success(msg % (_c_cmpt, _c_vrs))
        telegrot.success(msg % (_h_cmpt, _h_vrs))
    except Exception:
        _c_not = '[err]Not[/err]'
        log.error(f'{_c_not} possible to put in pause the ' +
                  f'component {_c_cmpt} with version {_c_vrs}')


@task
def push(c, component=None, version=None, stream=True, decode=True, username=None, password=None):
    __check_all(component, version)
    _pswd = '[hl]Password[/hl]'
    _user = '[hl]username[/hl]'
    _msg = '%s set but the %s is [err]missing[/err].'
    if username and password:
        auth_config = dict(username=username, password=password)
    elif not username:
        log.error(_msg % (_pswd, _user))
    elif not password:
        log.error(_msg % (_user, _pswd))
    else:
        auth_config = {}

    def __call():
        return client.images.push(__tag(component, version), stream=stream, decode=decode, auth_config=auth_config)
    if stream:
        for _output in __call():
            yield log.info(_output, line=True)
    else:
        log.info(__call())


@task
def run(c, component=None, version=None):
    __check_all(component, version)
    client.containers.run(__tag(component, version),
                          name=__cnt_name(component, version), detach=True)


@task
def shell(c, component=None, version=None):
    __check_all(component, version)
    __cnt(component, version).exec_run('/bin/bash',
                                       tty=True, privileged=True, detach=False)


def __check_all(component: str, version: str, **kwargs) -> None:
    __check(item=component, key='component')
    __check(item=version, key='version')
    for _k, _v in kwargs.items():
        __check(item=_v, key=_k)


def __check(item: str, key: str) -> None:
    if item is None:
        log.error(f'[err]Missing[/err] :{cfg.icon.get(key)}: [hl]{key}[/hl].')
        exit(1)


def __cnt(component, version):
    try:
        return client.containers.get(__cnt_name(component, version))
    except Exception:
        _c_not = '[err]not[/err]'
        log.error(f'Component :{cfg.icon.component}: [hl]{component}[/hl] with ' +
                  f'version :{cfg.icon.version}: [hl]{version}[/hl] {_c_not} found.')
        exit(2)


def __cnt_name(component, version):
    return f'{component}.{version}'


def __tag(container, version):
    return f'{cfg.project}project/{container}:{version}'
