#!/usr/bin/env bash

qemu-system-i386 -boot c -m 256 -hda build/main.img
