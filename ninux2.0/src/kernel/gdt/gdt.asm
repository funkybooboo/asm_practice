; Declare gdt_flush as a global symbol so it can be accessed from other files
global gdt_flush

; Define the gdt_flush function
gdt_flush:
    ; Move the pointer to the GDT descriptor (passed on the stack) into eax.
    ; [esp+4] is used because [esp] contains the return address.
    mov eax, [esp+4]
    
    ; Load the Global Descriptor Table Register (GDTR) with the new GDT descriptor.
    ; The descriptor is located at the memory address contained in eax.
    lgdt [eax]

    ; Set eax to the data segment selector (0x10). This assumes that the GDT is set up such that
    ; the data segment descriptor is at index 2 (0x10 when multiplied by 8).
    mov eax, 0x10
    
    ; Load the DS (Data Segment) register with the data segment selector.
    mov ds, ax
    ; Load the ES (Extra Segment) register with the data segment selector.
    mov es, ax
    ; Load the FS (Additional Data Segment) register with the data segment selector.
    mov fs, ax
    ; Load the GS (Additional Data Segment) register with the data segment selector.
    mov gs, ax
    ; Load the SS (Stack Segment) register with the data segment selector.
    mov ss, ax
    
    ; Perform a far jump to the new code segment to update the CS (Code Segment) register.
    ; 0x08 is the selector for the code segment, and .flush is the offset label.
    jmp 0x08:.flush
    
.flush:
    ; Return from the function.
    ret
