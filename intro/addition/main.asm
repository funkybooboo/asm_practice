section .data

section .text
global main

main:
    mov eax, 1
    mov ebx, 2
    add eax, ebx

    mov al, 0b11111111
    mov bl, 0b0001
    add al, bl

    adc ah, 0

    int 80h

