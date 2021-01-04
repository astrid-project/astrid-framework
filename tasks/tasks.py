#!/usr/bin/env inv
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

from invoke import Collection

import container
import repository

namespace = Collection(
    container,
    repository)
