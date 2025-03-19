global x86_div64_32
x86_div64_32:
    push bp               ; Save the current base pointer on the stack
    mov bp, sp            ; Establish a new stack frame by setting bp to the current stack pointer

    push bx               ; Save the bx register on the stack because it will be used later

    mov eax, [bp+8]       ; Load the upper 32 bits of the dividend into eax (first half of 64-bit dividend)
    mov ecx, [bp+12]      ; Load the divisor into ecx
    xor edx, edx          ; Clear edx to zero (ensuring the high part of the 64-bit dividend is zero)
    div ecx               ; Divide the 64-bit dividend (edx:eax) by ecx
                          ;   - Quotient goes into eax
                          ;   - Remainder goes into edx

    mov bx, [bp+16]       ; Load the pointer to the quotient storage location into bx
    mov [bx+4], eax       ; Store the upper 32 bits of the quotient at the address (bx + 4)

    mov eax, [bp+4]       ; Load the lower 32 bits of the dividend into eax
    div ecx               ; Divide the 64-bit number (previous remainder in edx combined with eax)
                          ; by ecx:
                          ;   - Quotient goes into eax
                          ;   - Remainder goes into edx

    mov [bx], eax         ; Store the lower 32 bits of the quotient at the address pointed to by bx
    mov bx, [bp+18]       ; Load the pointer to the remainder storage location into bx
    mov [bx], edx         ; Store the final remainder at the address pointed to by bx

    pop bx                ; Restore the original bx register value from the stack

    mov sp, bp            ; Restore the stack pointer from the base pointer (cleaning up the stack frame)
    pop bp                ; Restore the original base pointer from the stack

    ret                   ; Return from the function
