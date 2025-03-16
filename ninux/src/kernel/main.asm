org 0x0
bits 16

; ---------------------------------------------------------------------------
; Program Start
; Description:
;   - Loads and prints the boot message.
;   - Halts the system after printing.
; ---------------------------------------------------------------------------
start:
    mov si, os_boot_msg    ; input: pointer to boot message
    call print             ; print the boot message
    hlt                    ; halt the system

halt:
    jmp halt               ; infinite loop to halt execution

; ---------------------------------------------------------------------------
; Print Routine
; Description:
;   - Prints a null-terminated string using BIOS interrupt 0x10.
; Inputs:
;   - si: pointer to the string to print.
; Outputs:
;   - The string is displayed on the screen.
; ---------------------------------------------------------------------------
print:
    push si               ; preserve si (string pointer)
    push ax               ; preserve ax
    push bx               ; preserve bx

print_loop:
    lodsb                 ; load byte at [si] into al, increment si
    or al, al             ; check if end of string (al == 0)
    jz print_done         ; if zero, jump to done_print

    mov ah, 0x0e          ; BIOS teletype output function
    mov bh, 0             ; page number (0)
    int 0x10              ; call BIOS to print character
    jmp print_loop        ; repeat for next character

print_done:
    pop bx                ; restore bx
    pop ax                ; restore ax
    pop si                ; restore si
    ret                   ; return from subroutine

; ---------------------------------------------------------------------------
; Boot Message Data
; ---------------------------------------------------------------------------
os_boot_msg: db 'Ninux has booted!', 0x0d, 0x0a, 0
