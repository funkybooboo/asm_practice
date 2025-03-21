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

    uint32_t mod1 = *(uint32_t*)(bootInfo->mods_addr + 4);
    uint32_t physicalAllocStart = (mod1 + 0xfff) & ~0xfff;
    initMemory(physicalAllocStart, bootInfo->mem_upper * 1023);
    print("Memory is ready!\r\n");

    for(;;); // Halt
}
