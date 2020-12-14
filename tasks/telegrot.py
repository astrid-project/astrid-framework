#!/usr/bin/env inv
# Copyright (c) 2020 ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

from config import config
from emoji import emojize
from functools import partial
from invoke import task
from log import logger
from telegram import Bot, ParseMode
from telegram.ext import CommandHandler, Filters, MessageHandler, Updater
import os
import requests

log = logger('telegrot')
cfg = config('icon', 'projects', 'platforms', 'telegrot')


class Telegrot:
    def __init__(self, token: str, chat_id: str):
        if token is None or chat_id is None:
            log.error(
                f'Missing [hl]token[/hl] and [hl]chat_id[/hl].')
            exit(1)
        self.bot = Bot(token=token)
        self.token = token
        self.chat_id = chat_id

    def error(self, msg: str):
        self.send(msg=f':{cfg.icon.error}: {msg}')

    def info(self, msg: str):
        self.send(msg=f':{cfg.icon.info}: {msg}')

    def warn(self, msg: str):
        self.send(msg=f':{cfg.icon.warn}: {msg}')

    def success(self, msg: str):
        self.send(msg=f':{cfg.icon.success}: {msg}')

    def send(self, msg: str=None, photo: str=None):
        if msg is None and photo is None:
            log.error(f'Missing :message: msg and/or :picture: photo.')
            exit(1)
        _txt = None
        if msg:
            _txt = emojize(msg, use_aliases=True)
            self.bot.send_message(chat_id=self.chat_id,
                                  text=_txt, parse_mode=ParseMode.HTML)
        if photo:
            if os.path.exists(photo):
                __send_photo = self.bot.send_photo
                if _txt is not None:
                    __send_photo = partial(__send_photo, caption=_txt)
                __send_photo(chat_id=self.chat_id, photo=open(photo, 'rb'))
            else:
                log.error(f'Photo [hl]{photo}[/hl] [err]not[/err] found.')
                exit(2)

telegrot = Telegrot(token=cfg.telegrot.token, chat_id=cfg.telegrot.chat_id)

class Data:
    selected_platform = None

@task
def serve(c):
    tg = telegrot
    updater = Updater(token=tg.token, use_context=True)
    dispatcher = updater.dispatcher

    def platform(update, context):
        input_platform = ' '.join(context.args)
        if not input_platform:
            if Data.selected_platform:
                tg.info(
                    f'Current :computer: platform: <b>{Data.selected_platform}</b>.')
            else:
                tg.error(f':computer: Platform: <u>not</u> <i>set</i>')
        elif input_platform in cfg.platforms:
            Data.selected_platform = input_platform
        else:
            tg.error(f':computer: Platform {input_platform} <b>unknown</b>.')
            tg.info(
                f'Possible values: {", ".join(map(lambda x: f"<b>{x}</b>", cfg.platforms))}')

    def cb_manager(update, context):
        if Data.selected_platform is None:
            tg.error(f'Missing :computer: <b>platform</b>.')
        elif len(context.args) == 2:
            method, uri = context.args
            http_methods = ['get', 'post', 'put', 'delete']
            if method in http_methods:
                m = getattr(requests, method)
                r = m(f'http://{cfg.platforms[Data.selected_platform]}/{uri}')
                tg.send(msg=r.text)
            else:
                tg.error(f'<u>Not</u> <u>valid</u> arguments.')
                tg.info(
                    f'Possible HTTP methods: {", ".join(map(lambda x: f"<b>{x}</b>", http_methods))}')
        else:
            tg.error(f'<u>Not</u> <u>valid</u> arguments.')
            tg.info(f'Must be: <i>HTTP method</i> <i>uri</i>.')

    def unknown(update, context):
        tg.error('<b>Unknown</b> command.')

    dispatcher.add_handler(CommandHandler('platform', platform))
    dispatcher.add_handler(CommandHandler('cbman', cb_manager))
    dispatcher.add_handler(MessageHandler(Filters.command, unknown))

    log.info(f'Starting [HL]{cfg.project.upper()}[/hl] Project Bot.')
    try:
        updater.start_polling()
        log.success(f'[hl]{cfg.project.upper()}[/hl] Project Bot started.')
        updater.idle()
    except Exception:
        log.error(
            f'[dng]Not[/dng] possible to start [hl]{cfg.project.upper()}[/hl] Project Bot.')
