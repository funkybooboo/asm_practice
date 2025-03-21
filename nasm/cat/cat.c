#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    // If no file is provided, read from standard input
    if (argc < 2) {
        char buffer[BUFSIZ];
        size_t n;
        while ((n = fread(buffer, 1, BUFSIZ, stdin)) > 0) {
            fwrite(buffer, 1, n, stdout);
        }
    } else {
        // Iterate over each file provided as an argument
        for (int i = 1; i < argc; i++) {
            FILE *fp = fopen(argv[i], "r");
            if (fp == NULL) {
                perror(argv[i]);
                continue;
            }
            char buffer[BUFSIZ];
            size_t n;
            while ((n = fread(buffer, 1, BUFSIZ, fp)) > 0) {
                fwrite(buffer, 1, n, stdout);
            }
            fclose(fp);
        }
    }
    return 0;
}
