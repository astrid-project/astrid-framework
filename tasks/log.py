#!/usr/bin/env inv
# Copyright (c) 2020 ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

from logging import Formatter as DefaultFormatter, LogRecord, Logger, getLogger
from re import sub
from config import config
from inspect import FrameInfo, getframeinfo, stack
from logging.handlers import SocketHandler, TimedRotatingFileHandler
from os import path
from rich.console import Console
from rich.logging import RichHandler
from rich.traceback import install
from style import theme
from utils import StdClass

install(show_locals=False)

cfg = config(log=['console', 'file', 'net', 'logger'])

icon = StdClass(exit='door', code='pager')


class Formatter(DefaultFormatter):
    @staticmethod
    def info(name: str) -> FrameInfo:
        for _s in stack():
            if name in _s.filename.replace('_', '-'):
                return _s

    def format(self, record: LogRecord) -> str:
        _s = self.info(record.name)
        record.calledfilename = path.basename(_s.filename)
        record.calledfunction = _s.function
        record.calledlineno = _s.lineno
        record.levelstyle = record.levelname.lower()
        return DefaultFormatter.format(self, record)


class NoStyleFormatter(Formatter):
    def format(self, record: LogRecord) -> str:
        _out = DefaultFormatter.format(self, record)
        _out = sub(r'\[[^\]]*\]([^\]]*)\[\/[^\]]*\]', r'\1', _out)
        _out = sub(r':[A-Za-z-_]*:[ ]{0,1}', '', _out)
        return _out


def logger(name: str) -> Logger:
    _log = getLogger(name)

    _log.console = Console(theme=theme)
    _hndl_console = RichHandler(markup=True,
                                show_time=False,
                                show_level=False,
                                show_path=False,
                                rich_tracebacks=True,
                                tracebacks_show_locals=True,
                                console=_log.console)
    if cfg.console.has('format'):
        _hndl_console.setFormatter(Formatter(cfg.console.format))
    if cfg.console.has('level'):
        _hndl_console.setLevel(cfg.console.level)
    _log.addHandler(_hndl_console)

    _hndl_file = TimedRotatingFileHandler(filename=f'{cfg.file.path}/{name}.log',
                                          when=cfg.file.when,
                                          interval=cfg.file.interval)
    if cfg.file.has('format'):
        _hndl_file.setFormatter(NoStyleFormatter(cfg.file.format))
    if cfg.file.has('level'):
        _hndl_file.setLevel(cfg.file.level)
    _log.addHandler(_hndl_file)

    _hndl_net = SocketHandler(host=cfg.net.get(
        'host', 'localhost'), port=cfg.net.get('port', 8765))
    if cfg.net.has('format'):
        _hndl_net.setFormatter(NoStyleFormatter(cfg.net.format))
    if cfg.net.has('level'):
        _hndl_net.setLevel(cfg.net.level)
    _log.addHandler(_hndl_net)

    _log.setLevel(cfg.logger.get(name, cfg.logger.__default__))

    def __response(r, ok, error, force={'ok': False, 'error': False, 'exit': True}):
        _stdout = r.stdout.strip()
        _stderr = r.stderr.strip()
        if r.ok:
            if _stderr and not force.get('ok', False):
                for l in _stderr.splitlines():
                    _log.warning(l)
            elif _stdout and not force.get('ok', False):
                for l in _stdout.splitlines():
                    _log.info(l)
            else:
                _log.info(ok)
        else:
            if _stderr and not force.get('error', False):
                for l in _stderr.strip().splitlines():
                    _log.error(l)
            elif _stdout and not force.get('error', False):
                for l in _stdout.strip().splitlines():
                    _log.error(l)
            else:
                _log.error(error)
            _log.warning(
                f':{icon.exit}: [warn]Exit[/warn] :{icon.code}: code: [hl]{r.exited}[/hl]')
        if force.get('exit', True):
            exit(r.exited)
        else:
            return r.exited
    _log.response = __response

    return _log


class DisableHandler:
    def __init__(self, log: Logger, index: str):
        self.log = log
        self.index = index

    def __enter__(self):
        self.hndl = self.log.handlers[self.index]
        del self.log.handlers[self.index]

    def __exit__(self, exit_type, exit_value, exit_traceback):
        self.log.handlers.append(self.hndl)


class Section:
    def __init__(self, log: Logger, title: str):
        self.console = log.console
        self.title = title

    def __enter__(self):
        self.console.rule(self.title)

    def __exit__(self, exit_type, exit_value, exit_traceback):
        self.console.print()
