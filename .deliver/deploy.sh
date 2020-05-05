#!/bin/bash -ex

mix edeliver deploy release to production --verbose
mix edeliver restart production --verbose
mix edeliver migrate production up --verbose
