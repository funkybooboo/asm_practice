#pragma once

#include "../multiboot.h"
#include "../stdlib/stdint.h"
#include "../stdlib/stdio.h"

void initMemory(struct multiboot_info* bootInfo);
