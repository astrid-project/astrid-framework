#!/usr/bin/env inv
# Copyright (c) 2020 ASTRID
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
