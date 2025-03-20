#!/usr/bin/env bash

set -e

gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/kernel.c -o build/kernel.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/vga/vga.c -o build/vga.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/gdt/gdt.c -o build/gdt.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/util/util.c -o build/util.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/interrupts/idt.c -o build/idt.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/timer/timer.c -o build/timer.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/stdlib/stdio.c -o build/stdio.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/keyboard/keyboard.c -o build/keyboard.o
gcc -m32 -fno-stack-protector -fno-builtin -c src/kernel/memory/memory.c -o build/memory.o

nasm -f elf32 src/bootloader/boot.asm -o build/boot.o
nasm -f elf32 src/kernel/gdt/gdt.asm -o build/gdts.o
nasm -f elf32 src/kernel/interrupts/idt.asm -o build/idts.o
nasm -f elf32 src/kernel/stdlib/stdio.asm -o build/stdios.o

ld -m elf_i386 -T src/linker.ld -o build/kernel build/boot.o build/kernel.o build/vga.o build/gdt.o build/gdts.o build/util.o build/idt.o build/idts.o build/timer.o build/stdio.o build/keyboard.o build/stdios.o build/memory.o
