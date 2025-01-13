section .data
    msg db "Hello, World!", 0 ; Null-terminated string

section .text
    global main

main:
    ; Write 'Hello, World!' to stdout
    mov     rax, 1      ; 1 = write
    mov     rdi, 1      ; 1 = to stdout
    mov     rsi, msg    ; string to display in rsi
    mov     rdx, 13     ; length of the string without null-terminator
    syscall             ; display the string
    
    ; exit the program
    mov     rax, 60     ; 60 = exit
    xor     rdi, rdi    ; 0 = success exit code
    syscall             ; quit
