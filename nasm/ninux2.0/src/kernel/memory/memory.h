#pragma once

#include "../multiboot.h"
#include "../stdlib/stdint.h"
#include "../stdlib/stdio.h"
#include "../util/util.h"

#define KERNEL_START 0xc0000000
#define PAGE_FLAG_PRESENT (1 << 0)
#define PAGE_FLAG_WRITE (1 << 1)

extern uint32_t initial_page_dir[1024];

void initMemory(uint32_t physicalAllocStart, uint32_t memHigh);
void invalidate(uint32_t vaddr);
void initPmm(uint32_t memLow, uint32_t memHigh);
