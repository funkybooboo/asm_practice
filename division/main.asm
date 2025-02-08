section .data

section .text
global main

main:
    mov eax, 11
    mov ecx, 2
    div ecx ; uses a / 2. eax will get the result which is 5. edx will get the remainder which is 1.

    mov eax, 0xff
    mov ecx, 2
    idiv ecx ; treat as signed numbers

    int 80h

