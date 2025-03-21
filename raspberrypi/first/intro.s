.text 

.global _start

_start:
    mov r0, #65 // #65 is a 65 decimal number. If we exit the program use a code of 65.
    mov r7, #1 // Quit the program

swi 0 // software interrupt to the terminal

