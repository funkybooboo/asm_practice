#include "stdio/stdio.h"
#include "disk/disk.h"

void _cdecl cstart_(){
    // puts("Ninux from C!\r\n");
    // printf("Formatted: %% %c %s\r\n", 'f', "Hello");
    // printf("%d,%i,%x,%p,%ld",1234, -2134, 0x1a, 0x3a, -1000000000l);

    uint8_t error;
    x86_Disk_Reset(0, &error);
    printf("Error %d\r\n", error);
}
