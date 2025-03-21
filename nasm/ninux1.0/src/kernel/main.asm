bits 16

section _ENTRY class=CODE

extern _cstart_

global entry

entry:
    cli                 ; disable interrupts to ensure uninterrupted initialization
    mov ax, ds          ; copy the data segment register value into ax
    mov ss, ax          ; set the stack segment to the value in ax (align stack with data segment)
    mov sp, 0           ; initialize the stack pointer to 0
    mov bp, sp          ; set the base pointer equal to the stack pointer (common stack frame setup)
    sti                 ; re-enable interrupts after initialization

    call _cstart_       ; call the C runtime start function to begin program execution

    cli                 ; disable interrupts again before halting
    hlt                 ; halt the processor, ending execution
