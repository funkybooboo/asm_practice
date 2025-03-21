#pragma once

#include "../interrupts/idt.h"
#include "../util/util.h"
#include "../vga/vga.h"

void initTimer();
void onIrq0(struct InterruptRegisters *regs);