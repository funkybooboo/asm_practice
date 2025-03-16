section .data
    pathname dd "/home/nate/Projects/nasm_practice/opening_and_reading_files/test.txt"
    buffer_size db 1024

section .bss
    buffer: resb 1024

section .text
global main

main:
    mov eax, 5 ; open
    mov ebx, pathname
    mov ecx, 0 ; read only
    int 80h

    mov ebx, eax ; save file descripter
    mov eax, 3 ; read
    mov ecx, buffer ; into buffer
    mov ebx, 1024 ; this much data
    int 80h

    mov eax, 1
    mov ebx, 0
    int 80h ; exit

