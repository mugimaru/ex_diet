#!/bin/bash -ex

mix edeliver build release --verbose --plain
mix edeliver deploy release to production --verbose --plain
mix edeliver restart production --verbose --plain
mix edeliver migrate production up --verbose --plain
