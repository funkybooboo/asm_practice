extern printf ; tell nasm these are external commands that will be linked in later
extern exit

section .data
    msg dd "Hello World!", 0
    fmt db "Output is: %s", 10, 0 ; 10 is new line 

section .text
global main

main:
    push msg ; gcc will pop these off the stack and put them into printf. order matters!
    push fmt
    call printf  ; printf(fmt, msg)

    push 1
    call exit ; exit(1)

