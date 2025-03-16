#include "vga.h"
#include "gdt.h"

void kmain(void);

void kmain(void) {
    // reset();
    // print("Hello, World!\r\n");

    initGdt();
    print("GDT is done!\r\n");
}
