#include "kernel.h"

void kmain(uint32_t magic, struct multiboot_info* bootInfo) {
    reset();

    initGdt();
    print("GDT is ready!\r\n");

    initIdt();
    print("IDT is ready!\r\n");

    initTimer();
    print("Timer is ready!\r\n");

    initKeyboard();
    print("Keyboard is ready!\r\n");

//    initMemory(bootInfo);
//    print("Memory is ready!\r\n");

    for(;;); // Halt
}
