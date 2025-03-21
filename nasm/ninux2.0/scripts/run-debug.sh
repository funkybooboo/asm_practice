#!/usr/bin/env bash

set -e

./scripts/clean.sh
./scripts/build-debug.sh
./scripts/iso.sh
./scripts/boot-debug.sh

# `$ gdb Ninux/boot/kernel`
# `(gdb) target remote :1234`
# `(gdb) l`
# `(gdb) break initGdt`
# `(gdb) continue`
# select the boot on grub
# `(gdb) layout asm`
