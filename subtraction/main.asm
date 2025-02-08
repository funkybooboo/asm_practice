section .data

section .text
global main

main:
    mov eax, 5
    mov ebx, 3
    sub eax, ebx

    mov eax, 3
    mov ebx, 5
    sub eax, ebx ; check out eflags

    mov ebx, 2
    add eax, ebx

    int 80h

