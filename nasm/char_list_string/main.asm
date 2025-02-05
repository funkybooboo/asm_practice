        section .data
        char DB 'A'

        section .text
        global main

main:
        MOV bl, [char]
        MOV eax, 1
        INT 80h
