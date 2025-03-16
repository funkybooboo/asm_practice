#include "stdio.h"
#include "print.h"

void putc(char c){
    x86_Video_WriteCharTeletype(c,0);
}

void puts(const char* s){
    while (*s){
        putc(*s);
        s++;
    }
}

void puts_f(const char far* s){
    while (*s){
        putc(*s);
        s++;
    }
}

// Helper: Process a format specifier that appears after a '%'.
// This function reads optional length modifiers ('h' or 'l') and then the conversion specifier,
// performing the corresponding output and updating the argument pointer.
// It also updates the format string pointer so that it points past the specifier.
int* process_format_specifier(int* argp, const char** fmt_ptr) {
    int length = PRINTF_LENGTH_START;
    int radix = 10;
    bool sign = false;
    const char* fmt = *fmt_ptr;

    // Check for optional length modifiers.
    if (*fmt == 'h') {
        length = PRINTF_LENGTH_SHORT;
        fmt++;
        if (*fmt == 'h') {  // Two h's => short short.
            length = PRINTF_LENGTH_SHORT_SHORT;
            fmt++;
        }
    } else if (*fmt == 'l') {
        length = PRINTF_LENGTH_LONG;
        fmt++;
        if (*fmt == 'l') {  // Two l's => long long.
            length = PRINTF_LENGTH_LONG_LONG;
            fmt++;
        }
    }
    
    // Process the conversion specifier.
    switch (*fmt) {
        case 'c':
            putc((char)*argp);
            argp++;
            break;
        case 's':
            if (length == PRINTF_LENGTH_LONG || length == PRINTF_LENGTH_LONG_LONG) {
                puts_f(*(const char far**)argp);
                argp += 2;
            } else {
                puts(*(const char**)argp);
                argp++;
            }
            break;
        case '%':
            putc('%');
            break;
        case 'd':
        case 'i':
            radix = 10;
            sign = true;
            argp = printf_number(argp, length, sign, radix);
            break;
        case 'u':
            radix = 10;
            sign = false;
            argp = printf_number(argp, length, sign, radix);
            break;
        case 'X':
        case 'x':
        case 'p':
            radix = 16;
            sign = false;
            argp = printf_number(argp, length, sign, radix);
            break;
        case 'o':
            radix = 8;
            sign = false;
            argp = printf_number(argp, length, sign, radix);
            break;
        default:
            // Unknown specifier: do nothing.
            break;
    }
    
    // Move past the conversion specifier.
    fmt++;
    *fmt_ptr = fmt;
    return argp;
}

void _cdecl printf(const char* fmt, ...) {
    int* argp = (int*) &fmt;
    // Skip the pointer to fmt to point to the first variadic argument.
    argp++;

    // Process each character in the format string.
    while (*fmt) {
        if (*fmt != '%') {
            putc(*fmt);
            fmt++;
        } else {
            // Found a '%'; skip it and process the format specifier.
            fmt++; 
            argp = process_format_specifier(argp, &fmt);
        }
    }
}

const char possibleChars[] = "0123456789abcdef";

// Helper: Extract the number from argp based on the length and sign,
// update argp accordingly, and return the unsigned number and its sign.
void extract_number_and_update_argp(int** argp_ptr, int length, bool sign, 
                                           unsigned long long *number, int *number_sign) {
    int* argp = *argp_ptr;
    *number_sign = 1; // default positive

    switch (length) {
        case PRINTF_LENGTH_SHORT_SHORT:
        case PRINTF_LENGTH_SHORT:
        case PRINTF_LENGTH_START:
            if (sign) {
                int n = *argp;
                if (n < 0) {
                    n = -n;
                    *number_sign = -1;
                }
                *number = (unsigned long long)n;
            } else {
                *number = *(unsigned int*)argp;
            }
            *argp_ptr = argp + 1;
            break;
        case PRINTF_LENGTH_LONG:
            if (sign) {
                long int n = *(long int*)argp;
                if (n < 0) {
                    n = -n;
                    *number_sign = -1;
                }
                *number = (unsigned long long)n;
            } else {
                *number = *(unsigned long int*)argp;
            }
            *argp_ptr = argp + 2;
            break;
        case PRINTF_LENGTH_LONG_LONG:
            if (sign) {
                long long int n = *(long long int*)argp;
                if (n < 0) {
                    n = -n;
                    *number_sign = -1;
                }
                *number = (unsigned long long)n;
            } else {
                *number = *(unsigned long long int*)argp;
            }
            *argp_ptr = argp + 4;
            break;
    }
}

// Helper: Convert the number to a buffer using the given radix.
// Returns the number of characters written.
int convert_number_to_buffer(unsigned long long number, int radix, char* buffer) {
    int pos = 0;
    do {
        uint32_t rem;
        x86_div64_32(number, radix, &number, &rem);
        buffer[pos++] = possibleChars[rem];
    } while (number > 0);
    return pos;
}

// Helper: Print the buffer in reverse order.
void print_buffer_in_reverse(char* buffer, int length) {
    while (--length >= 0) {
        putc(buffer[length]);
    }
}

int* printf_number(int* argp, int length, bool sign, int radix) {
    char buffer[32];
    unsigned long long number;
    int number_sign = 1;
    int pos;

    // Extract the number from argp and update argp.
    extract_number_and_update_argp(&argp, length, sign, &number, &number_sign);
    
    // Convert the number into the buffer (digits in reverse order).
    pos = convert_number_to_buffer(number, radix, buffer);
    
    // If signed and the number was negative, add '-' to the buffer.
    if (sign && number_sign < 0) {
        buffer[pos++] = '-';
    }
    
    // Print the buffer in reverse order to output the number correctly.
    print_buffer_in_reverse(buffer, pos);
    
    return argp;
}
