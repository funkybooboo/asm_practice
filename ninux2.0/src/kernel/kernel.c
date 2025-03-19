#include "kernel.h"

void kmain(void) {
    // reset();
    // print("Hello, World!\r\n");

    initGdt();
    print("GDT is done!\r\n");
    initIdt();
    print("IDT is done!\r\n");
}
