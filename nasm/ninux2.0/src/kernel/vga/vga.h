#pragma once

#include "../stdlib/stdint.h"

#define COLOR8_BLACK 0
#define COLOR8_LIGHT_GREY 7

#define width 80
#define height 25

void print(const char* s);
void scrollUp();
void newLine();
void reset();
