section .data
    num DD 5

section .text
global main

main:
    MOV eax, 1
    MOV ebx, [num]
    INT 80h

