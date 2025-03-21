#pragma once

#include "../util/util.h"
#include "../interrupts/idt.h"
#include "../stdlib/stdint.h"
#include "../stdlib/stdbool.h"
#include "../stdlib/stdio.h"

void initKeyboard();
void keyboardHandler(struct InterruptRegisters* regs);
