#include "memory.h"

static uint32_t pageFrameMin;
static uint32_t pageFrameMax;
static uint32_t totalAlloc;

#define NUM_PAGE_DIRS 256
#define NUM_PAGE_FRAMES (0x100000000 / 0x1000 / 8)

uint8_t physicalMemoryBitmap[NUM_PAGE_DIRS / 8]; // TODO set dynamically, use bit array

static uint32_t pageDirs[NUM_PAGE_DIRS][1024] __attribute__((aligned(4096)));
static uint8_t usedPageDirs[NUM_PAGE_DIRS];

void invalidate(uint32_t vaddr) {
    asm volatile("invlpg %0" : : "m"(vaddr));
}

void initPmm(uint32_t memLow, uint32_t memHigh) {
    pageFrameMin = CEIL_DIV(memLow, 0x1000);
    pageFrameMax = memHigh / 0x1000;
    totalAlloc = 0;
    memset(physicalMemoryBitmap, 0, sizeof(physicalMemoryBitmap));
}

void initMemory(uint32_t physicalAllocStart, uint32_t memHigh) {
    initial_page_dir[0] - 0;
    invalidate(0);
    initial_page_dir[1023] = ((uint32_t) initial_page_dir - KERNEL_START) | PAGE_FLAG_PRESENT | PAGE_FLAG_WRITE;
    invalidate(0xfffff000);

    initPmm(physicalAllocStart, memHigh);
    memset(pageDirs, 0, 0x1000 * NUM_PAGE_DIRS);
    memset(usedPageDirs, 0, NUM_PAGE_DIRS);
}
