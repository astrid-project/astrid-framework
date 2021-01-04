#!/usr/bin/env inv
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

from rich.theme import Theme

BOLD_CYAN = 'bold cyan'
BOLD_GREEN = 'bold green'
BOLD_RED = 'bold red'
BOLD_YELLOW = 'bold yellow'

theme = Theme({
    'err': BOLD_RED,
    'error': BOLD_RED,
    'filename': BOLD_GREEN,
    'function': BOLD_YELLOW,
    'hl': 'purple',
    'inf': BOLD_CYAN,
    'info': BOLD_CYAN,
    'lineno': BOLD_RED,
    'log-name': 'bold purple',
    'log-time': 'cyan',
    'ok': BOLD_GREEN,
    'success': BOLD_GREEN,
    'warn': BOLD_YELLOW,
    'warning': BOLD_YELLOW
})
