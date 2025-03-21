#!/usr/bin/env bash

set -e

qemu-system-i386 -boot c -m 256 -hda build/main.img -s -S

# to connect to the debugger
# `$ gdb`
# `(gdb) target remote localhost:1234` 1234 is the port qemu's debugger is listening on
# note jump over interrupts for easy debugging
