section .data

section .text
global main

addTwo:
    push ebp ; use ebp as a referance to the top of the stack
    mov ebp, esp ; stack pointer

    ; ebp <- stack pointer +0
    ; return address +4
    ; 1 +8
    ; 4 +12
    
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    add eax, ebx

    pop ebp ; get back to the return address
    ret ; return back to the locaion we where called from

main:
    push 4
    push 1
    call addTwo
    mov ebx, eax
    mov eax, 1

    int 80h
