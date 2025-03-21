#include "util.h"

void memset(void* dest, char value, uint32_t count) {
    char* temp = (char*) dest;
    for (; count != 0; count--) {
        *temp++ = value;
    }
}

void outPortB(uint16_t port, uint8_t value) {
    asm volatile ("outb %1, %0" : : "dN" (port), "a" (value));
}

char inPortB(uint16_t port) {
    char rv;
    asm volatile ("inb %1, %0" : "=a"(rv) : "dN"(port));
}
