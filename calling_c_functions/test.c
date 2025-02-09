#include <stdio.h>

extern int test(int, int);

int test(int a, int b) {
    printf("HERE!\n");
    return a + b;
}

