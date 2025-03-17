; Set the code to 32-bit mode
bits 32

; Begin the text (code) section
section .text
    ; Align the following data on a 4-byte boundary
    align 4
    ; Define a 32-bit word with a specific magic number (often used for boot loader verification)
    dd 0x1badb002
    ; Define a 32-bit word with a zero value (could represent flags or reserved field)
    dd 0x00000000
    ; Define a 32-bit word with the negative sum of the previous values (commonly used as a checksum)
    dd -(0x1badb002 + 0x00000000)

; Declare the global entry point for the linker
global start
; Declare an external function named kmain (kernel main) that will be provided elsewhere
extern kmain

; Define the entry point of the program
start:
    ; Disable interrupts to ensure that the CPU does not get interrupted during setup
    cli
    ; Initialize the stack pointer with the address of stack_space
    mov esp, stack_space
    ; Call the kmain function (the main function of the kernel)
    call kmain
    ; Halt the CPU after kmain returns, stopping further execution
    hlt

; Define a label for an infinite halt loop (as a fallback or for error states)
halt:
    ; Disable interrupts again to ensure the CPU remains halted
    cli
    ; Halt the CPU
    hlt
    ; Jump back to the halt label, creating an infinite loop to prevent further execution
    jmp halt

; Begin the bss section for uninitialized data
section .bss
; Reserve 8192 bytes (8KB) of space for uninitialized data (e.g., used as a stack or other purposes)
resb 8192
; Define a label for the stack space, which is used to set the stack pointer
stack_space:
