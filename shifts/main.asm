section .data

section .text
global main

main:
    mov eax, 2
    shr eax, 1   ; shift to the right by 1. 0010 -> 0001. same thing as a = a / 2

    mov eax, 2
    shl eax, 1   ; shift to the left by 1. 0010 -> 0100. same thing as a = a * 2

    ;sar   ; a signed shift. shift but keep the signed bit the same
    ;asl

    int 80h

