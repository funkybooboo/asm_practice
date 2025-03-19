#include "kernel.h"

void kmain(void) {
    reset();

    initGdt();
    print("GDT is ready!\r\n");

    initIdt();
    print("IDT is ready!\r\n");

    initTimer();
    print("Timer is ready!\r\n");

    initKeyboard();
    print("Keyboard is ready!\r\n");

    for(;;); // Halt
}
