section .bss
    num resb 3 ; reserve a byte

section .data
    num2 db 3 dup(2) ; put 3 different instances of 2 into the 3 slots

section .text
global main

main:
    mov bl, 1
    mov [num], bl
    mov [num + 1], bl
    mov [num + 2], bl
    int 80h

