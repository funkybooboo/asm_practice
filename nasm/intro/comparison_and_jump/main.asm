section .data

section .text
global main

main:
    mov eax, 3
    mov ebx, 2
    
    cmp eax, ebx   ; compaire   a - b = 1 but we dont care about the value we just care about positive negative or 0
    
    jl lesser    ; jump if less then a < b
    jmp end     ; jump

lesser:
    mov ecx, 1
    
end:
    int 80h

; jump if
; jl lesser then
; jg greater then
; je equals
; jne not equals
; jge greater then or equal to
; jle less then or equal to
; jz  equal to 0
; jnz  not equal to 0

