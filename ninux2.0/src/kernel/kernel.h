#pragma once

#include "gdt/gdt.h"
#include "interrupts/idt.h"
#include "vga/vga.h"
#include "timer/timer.h"
#include "keyboard/keyboard.h"
#include "multiboot.h"
#include "memory/memory.h"

void kmain(uint32_t magic, struct multiboot_info* bootInfo);
