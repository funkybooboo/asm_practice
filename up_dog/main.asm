        section .data
msg1:
        db "It smells like up dog.", 10, 0
        msg1_len equ $ - msg1 - 1      ; measure the length of msg1, minux the 0
msg2:
        db "What's up dog?", 10, 0
        msg2_len equ $ - msg2 - 1

        section .text
        global main

main:
        push rbp                       ; function prologue
        mov rbp, rsp                   ; function prologue

        mov rax, 1                     ; write
        mov rdi, 1                     ; to stdout
        mov rsi, msg1                  ; string to display
        mov rdx, msg1_len
        syscall                        ; dislay the string

        mov rax, 1                     ; write
        mov rdi, 1                     ; to stdout
        mov rsi, msg2
        mov rdx, msg2_len
        syscall

        mov rsp, rbp                   ; function epilogue
        pop rbp                        ; function epilogue

        mov rax, 60                    ; exit
        mov rdi, 0                     ; exit code

        syscall
