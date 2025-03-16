section .data
    list db 1, 2, 3, 4
    listLength db 4
section .text
global main

main:
    mov eax, 0 ; keep track of index
    mov ecx, 0 ; sum of numbers in the list

loop:
    mov ebx, [list + eax] ; get the value at the index
    add ecx, ebx ; c = c + b
    inc eax

    cmp eax, [listLength]
    je end
    jmp loop

end:
    mov eax, 1
    mov ebx, 1
    int 80h
