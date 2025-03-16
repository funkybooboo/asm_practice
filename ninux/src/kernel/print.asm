bits 16

section _TEXT class=CODE

global _x86_div64_32
_x86_div64_32:
    push bp
    mov bp, sp

    push bx

    mov eax, [bp+8] ; upper 32 bits of dividends
    mov ecx, [bp+12] ; divisor
    xor edx, edx
    div ecx

    mov bx, [bp+16] ; upper 32 bits of the quotient
    mov [bx+4], eax

    mov eax, [bp+4] ; lower 32 bits of the dividend
    div ecx

    mov [bx], eax
    mov bx, [bp+18]
    mov [bx], edx

    pop bx

    mov sp, bp
    pop bp

    ret

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
