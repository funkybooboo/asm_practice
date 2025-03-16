bits 16

section _TEXT class=CODE

global _x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
    push bp              ; save the base pointer
    mov bp, sp           ; establish a new stack frame

    push bx              ; save bx register (preserved across calls)

    mov ah, 0eh          ; function 0Eh: teletype output (BIOS video service)
    mov al, [bp+4]       ; load the character to display (first argument)
    mov bh, [bp+6]       ; load the page number (second argument)

    int 10h              ; call BIOS video interrupt to display the character

    pop bx               ; restore bx register
    mov sp, bp           ; restore the original stack pointer

    pop bp               ; restore the base pointer

    ret                  ; return to the caller
