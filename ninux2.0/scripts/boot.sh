#!/usr/bin/env bash

set -e

rm -rf build/
mkdir -p build/Ninux/boot/grub/

gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel.c -o build/kernel.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/vga.c -o build/vga.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/gdt.c -o build/gdt.o

nasm -f elf32 src/bootloader/boot.asm -o build/boot.o
nasm -f elf32 src/gdt.asm -o build/gdts.o

ld -m elf_i386 -T src/linker.ld -o build/kernel build/boot.o build/kernel.o build/vga.o build/gdt.o build/gdts.o

cp build/kernel build/Ninux/boot/
cp configs/grub.cfg build/Ninux/boot/grub/

grub-mkrescue -o build/Ninux.iso build/Ninux/
qemu-system-i386 build/Ninux.iso
