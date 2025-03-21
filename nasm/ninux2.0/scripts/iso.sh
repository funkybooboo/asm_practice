#!/usr/bin/env bash

set -e

cp build/kernel build/Ninux/boot/
cp grub.cfg build/Ninux/boot/grub/

grub-mkrescue -o build/Ninux.iso build/Ninux/
