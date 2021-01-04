#!/usr/bin/env inv
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

import container
import repository
import service
import telegrot
from invoke import Collection, task


namespace = Collection(
    container,
    repository,
    service,
    telegrot)
