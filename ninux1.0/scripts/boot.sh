#!/usr/bin/env bash

set -e

# qemu-system-i386 -boot c -m 256 -hda build/main.img

qemu-system-i386 -fda build/main.img
