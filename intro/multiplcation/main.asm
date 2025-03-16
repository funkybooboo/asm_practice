section .data

section .text
global main

main:
    mov al, 2
    mov bl, 3
    mul bl    ; automacally uses the a register a = a * b

    mov al, 0xff
    mov bl, 3
    mul bl    ; automacally uses ax to expaned multiplicaiton if result is too big

    mov al, 0xff
    mov bl, 2
    imul bl    ; deal with signed numbers

    int 80h

