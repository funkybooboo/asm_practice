global idt_flush
idt_flush:
    mov eax, [esp+4]    ; Load the pointer to the IDT descriptor (passed on the stack) into EAX
    lidt [eax]          ; Load the Interrupt Descriptor Table using the descriptor pointed by EAX
    sti                 ; Set the interrupt flag to enable interrupts
    ret                 ; Return from the procedure

%macro ISR_NOERRCODE 1
    global isr%1
    isr%1:
        cli             ; Disable interrupts
        push long 0     ; Push a dummy error code (0) to align the stack for ISRs without an error code
        push long %1    ; Push the interrupt number onto the stack
        jmp isr_common_stub   ; Jump to the common interrupt service routine handler
%endmacro

%macro ISR_ERRCODE 1
    global isr%1
    isr%1:
        cli             ; Disable interrupts
        push long %1    ; Push the interrupt number (error code already present) onto the stack
        jmp isr_common_stub   ; Jump to the common interrupt service routine handler
%endmacro

%macro IRQ 2
    global irq%1
    irq%1:
        cli             ; Disable interrupts
        push long 0     ; Push a dummy error code (0) to maintain stack consistency for IRQs
        push long %2    ; Push the IRQ number onto the stack
        jmp irq_common_stub   ; Jump to the common IRQ handler routine
%endmacro

ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE 8
ISR_NOERRCODE 9
ISR_ERRCODE 10
ISR_ERRCODE 11
ISR_ERRCODE 12
ISR_ERRCODE 13
ISR_ERRCODE 14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31
IRQ 0, 32  
IRQ 1, 33  
IRQ 2, 34  
IRQ 3, 35  
IRQ 4, 36  
IRQ 5, 37  
IRQ 6, 38  
IRQ 7, 39  
IRQ 8, 40  
IRQ 9, 41  
IRQ 10, 42  
IRQ 11, 43  
IRQ 12, 44  
IRQ 13, 45  
IRQ 14, 46  
IRQ 15, 47 
ISR_NOERRCODE 128
ISR_NOERRCODE 177

%macro COMMON_STUB 2
    extern %2
    global %1
    %1:
        pusha                   ; Save all general-purpose registers on the stack
        mov eax, ds             ; Move the current data segment selector into EAX
        push eax                ; Save the original data segment register value on the stack
        mov eax, cr2            ; Read the CR2 register (faulting address on page fault) into EAX
        push eax                ; Push the faulting address onto the stack

        mov ax, 0x10            ; Load the kernel data segment selector (0x10) into AX
        mov ds, ax              ; Set DS to the kernel data segment
        mov es, ax              ; Set ES to the kernel data segment
        mov fs, ax              ; Set FS to the kernel data segment
        mov gs, ax              ; Set GS to the kernel data segment

        push esp                ; Push the current stack pointer to pass the pointer to the handler
        call %2                 ; Call the external handler function (ISR or IRQ handler)
        add esp, 8              ; Clean up the two values pushed earlier (faulting address and original DS)

        pop ebx                 ; Retrieve the saved original DS from the stack into EBX
        mov ds, bx              ; Restore DS from EBX
        mov es, bx              ; Restore ES from EBX
        mov fs, bx              ; Restore FS from EBX
        mov gs, bx              ; Restore GS from EBX

        popa                    ; Restore all general-purpose registers
        add esp, 8              ; Remove the pushed error code and interrupt/IRQ number from the stack
        sti                     ; Enable interrupts by setting the interrupt flag
        iret                    ; Return from the interrupt, restoring execution context
%endmacro

COMMON_STUB isr_common_stub, isr_handler
COMMON_STUB irq_common_stub, irq_handler
