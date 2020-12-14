#!/usr/bin/env inv
# Copyright (c) 2020 ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

from platform import platform
from config import config
from git.cmd import Git
from invoke import task
from log import logger
from telegrot import telegrot
from utils import _, joinmap, StdClass
import os

log = logger('repository')
cfg = config('platforms', repository=['git', 'platforms'])


@task
def checkout(c, name=None):
    _platform = __platform()
    _c_name, _c_platform = f'[hl]{name}[/hl]', f'[hl]{_platform}[/hl]'
    _h_name, _h_platform = f'<b>{name}</b>', f'<b>{_platform}</b>'
    _msg = f'Checkout of :{cfg.icon.component}: %s %s completed @ :{cfg.icon.platform}: %s.'
    try:
        _git = Git(cfg.git.get(name))
        _git.checkout()
        log.success(_msg % (_c_name, '[ok]correctly[/ok]', _c_platform))
        telegrot.success(_msg % (_h_name, '<u>correctly</u>', _h_platform))
        exit(0)
    except Exception:
        log.error(_msg % (_c_name, '[err]not[/err]', _c_platform))
        telegrot.error(_msg % (_h_name, '<u>not</u>', _h_platform))
        exit(1)


@task
def pull(c, name=None):
    __check(name)
    _platform = __platform()
    _c_name, _c_platform = f'[hl]{name}[/hl]', f'[hl]{_platform}[/hl]'
    _h_name, _h_platform = f'<b>{name}</b>', f'<b>{_platform}</b>'
    _msg = f'Pull of :{cfg.icon.component}: %s %s completed @ :{cfg.icon.platform}: %s.'
    try:
        _git = Git(cfg.git[name])
        _git.pull()
        log.success(_msg % (_c_name, '[ok]correctly[/ok]', _c_platform))
        telegrot.success(_msg % (_h_name, '<u>correctly</u>', _h_platform))
        exit(0)
    except Exception:
        log.error(_msg % (_c_name, '[err]not[/err]', _c_platform))
        telegrot.error(_msg % (_h_name, '<u>not</u>', _h_platform))
        exit(1)


def __check(name: str):
    _msg = 'Repository available: ' + joinmap(_('[hl]%s[/hl]'), cfg.git)
    if name is None:
        log.error(f'[err]Missing[/err] [hl]name[/hl].')
        log.info(_msg)
        exit(1)
    elif not name in cfg.git:
        _c_name, _c_unknown = f'[hl]{name}[/hl]', '[err]unknown[/err]'
        log.error(f'Repository :{cfg.icon.repository}:' +
                  f'{_c_name} {_c_unknown}.')
        log.info(_msg)
        exit(2)


def __platform():
    _home_path = os.environ["HOME"]
    for _platform in cfg.platforms:
        if os.path.exists(os.path.join(_home_path, _platform)):
            return cfg.platforms[_platform]
    return 'unknown'
