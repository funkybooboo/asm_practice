section .data
    x dd 3.14
    y dd 2.1

section .text
global main

main:
    movss xmm0, [x] ; move scaler single presion. xmm0-xmm15. 
    movss xmm1, [y]
    addss xmm0, xmm1 ; x0 = x0 + x1

    ucomiss xmm0, xmm1 ; compare
    ja greater
    jmp end
    ;jb ; jump below (<)
    ;jbe 
    ;jae
    ;ja ; jump above (>)
    ;je ; can still use

    int 80h

greater:
    mov ecx, 1

end:
    int 80h

