section .data
    pathname dd "/home/nate/Projects/nasm_practice/creating_writing_files/test.txt"
    toWrite dd "Hello, World!",0ah,0dh,"$"
section .bss

section .text
global main

main:
    mov eax, 5
    mov ebx, pathname
    mov ecx, 101o
    mov edx, 700o
    int 80h

    mov ebx, eax
    mov eax, 4
    mov ecx, toWrite
    mov edx, 16
    int 80h

    mov eax, 1
    mov ebx, 0
    int 80h
