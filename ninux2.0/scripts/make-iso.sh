gcc -m32 -fno-stack-protector -fno-builtin -c kernel.c -o kernel.o
nasm -f elf32 boot.asm -o boot.o
ld -m elf_i386 -T linker.ld -o kernel boot.o kernel.o
mv kernel Ninux/boot/kernel/
grub-mkrescue -o Ninux.iso Ninux/
qemu-system-i386 Ninux.iso
