#!/usr/bin/env bash

set -e

gcc -m32 -fno-stack-protector -fno-builtin -c kernel.c -o kernel.o
gcc -m32 -fno-stack-protector -fno-builtin -c vga.c -o vga.o
nasm -f elf32 boot.asm -o boot.o
ld -m elf_i386 -T linker.ld -o kernel boot.o kernel.o vga.o
rm -rf Ninux/boot/kernel
mv kernel Ninux/boot/
grub-mkrescue -o Ninux.iso Ninux/
qemu-system-i386 Ninux.iso
