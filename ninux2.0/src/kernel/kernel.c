#include "kernel.h"
#include "gdt/gdt.h"
#include "interrupts/idt.h"
#include "vga/vga.h"
#include "timer/timer.h"

void kmain(void) {
    // reset();
    // print("Hello, World!\r\n");

    initGdt();
    print("GDT is done!\r\n");

    initIdt();
    print("IDT is done!\r\n");

    initTimer();

}
