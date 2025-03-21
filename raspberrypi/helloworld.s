.global _start

_start:
    mov r7, #4 # write
    mov r0, #1 # to stdout
    mov r2, #12 # this many bytes
    ldr r1, =message # here are the bytes
    swi 0

end:
    mov r7, #1
    swi 0

.data

message:
    .ascii "Hello World\n"

