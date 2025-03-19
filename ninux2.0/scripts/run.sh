#!/usr/bin/env bash

set -e

./scripts/clean.sh
./scripts/build.sh
./scripts/iso.sh
./scripts/boot.sh
