section .text
global main

main:
    mov eax, 0b1010
    mov ebx, 0b1100
    and eax, ebx

    mov eax, 0b1010
    mov ebx, 0b1100
    or eax, ebx

    not eax
    
    mov eax, 0b1010
    not eax
    and eax, 0xF    ; mask: clear everything but the last 4 bits
    
    mov eax, 0b1010
    mov ebx, 0b1100
    xor eax, ebx

    int 80h

