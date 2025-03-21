.global _start

// <instruction> <destination>, <operand>, <operand>

_start:
    mov r7, #3 // read
    mov r0, #0 // from stdin
    mov r2, #10 // this many bytes
    ldr r1, =message // read into
    swi 0 // sys call

_write:
    mov r7, #4 // write
    mov r0, #1 // to stdout
    mov r2, #10 // this many bytes
    ldr r1, =message // here are the bytes
    swi 0

end:
    mov r7, #1
    swi 0

.data

message:
    .ascii ""

