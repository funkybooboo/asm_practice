extern test

section .data
section .text
global main

main:
    push 1
    push 2
    call test ; test(2, 1)
    push eax ; get the return value

    int 80h

