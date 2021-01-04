#!/usr/bin/env inv
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

from typing import Callable
import json


def _(out: str) -> any:
    return lambda x: out.format(x)


def joinmap(func: Callable, sequence: list, sep: str = ', ') -> str:
    return sep.join(map(func, sequence))


class StdClass:
    def __init__(self, **kwargs):
        for k, v in kwargs.items():
            self.set(k, v)

    def set(self, k: str, v: any):
        if isinstance(v, dict):
            setattr(self, k, StdClass(**v))
        else:
            setattr(self, k, v)

    def get(self, k: str, default: any = None) -> any:
        if self.has(k):
            return getattr(self, k)
        return default

    def has(self, k: str) -> bool:
        return hasattr(self, k)

    def to_dict(self) -> dict:
        return json.loads(json.dumps(self, default=lambda o: o.__dict__))
