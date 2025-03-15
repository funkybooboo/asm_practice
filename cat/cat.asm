; main.asm - A simple "cat" clone written in NASM (x86-64 Linux)
; 
; Overview:
;   This program mimics the basic functionality of the Unix "cat" command.
;   It opens a file specified by a command-line argument, reads its content into
;   a buffer, and writes that content to standard output (stdout). If an error occurs,
;   it prints an error message to standard error (stderr) and exits.
;
; Assembling and linking:
;   To assemble this code into an object file:
;       nasm -f elf64 main.asm -o main.o
;   To link the object file into an executable:
;       ld main.o -o main
;
; Running the program:
;   ./main filename
;   (Replace "filename" with the path to the file you want to display.)
;
; --------------------------------------------------------------------------------
; System Calls and Constants:
;   We use Linux system calls directly. Each call is made by placing the system
;   call number in register RAX, setting up any required arguments in other registers,
;   and then executing the "syscall" instruction.
;
;   Defined system calls:
;     - SYS_READ (0)    : Read from a file descriptor.
;     - SYS_WRITE (1)   : Write to a file descriptor.
;     - SYS_OPENAT (257): Open a file (using openat, which lets us specify the directory).
;     - SYS_CLOSE (3)   : Close a file descriptor.
;     - SYS_EXIT (60)   : Exit the program.
;
;   Additional constants:
;     - AT_FDCWD (-100): Indicates that openat() should use the current working directory.
;     - O_RDONLY (0)   : Open file in read-only mode.
;
; --------------------------------------------------------------------------------

%define SYS_READ    0       ; System call number for read()
%define SYS_WRITE   1       ; System call number for write()
%define SYS_OPENAT  257     ; System call number for openat()
%define SYS_CLOSE   3       ; System call number for close()
%define SYS_EXIT    60      ; System call number for exit()

%define AT_FDCWD    -100    ; Use the current working directory.
%define O_RDONLY    0       ; Open file in read-only mode.

global _start

; Data Section:
section .data
    ; Define the size of our I/O buffer (4KB).
    buffer_size equ 4096

    ; Create a buffer for reading file content; initialized to zero.
    buffer: times buffer_size db 0

    ; Error messages to display if file operations fail.
    open_err_msg: db "Error: Cannot open file", 10   ; Message for open errors, ending with newline.
    open_err_msg_len equ $ - open_err_msg           ; Automatically calculates message length.

    read_err_msg: db "Error: Reading file", 10        ; Message for read errors.
    read_err_msg_len equ $ - read_err_msg             ; Calculates message length.

; --------------------------------------------------------------------------------
; Text Section: Contains code including helper functions and main program logic.
section .text

; ----------------------------------------------------------------------------
; Function: exit_program
; Purpose:
;   Terminates the program by making a system call.
; Inputs:
;   - rdi: The exit code to return to the operating system.
; Behavior:
;   Loads the exit system call number (SYS_EXIT) into rax and executes "syscall".
;   This function does not return.
exit_program:
    mov rax, SYS_EXIT  ; Load exit syscall number (60) into RAX.
    syscall            ; Call the kernel to exit, using RDI as the exit code.
    ; (No return - program stops here.)

; ----------------------------------------------------------------------------
; Function: print_string
; Purpose:
;   Writes a string to a specified file descriptor.
; Inputs:
;   - rdi: File descriptor (1 for stdout, 2 for stderr).
;   - rsi: Pointer to the string in memory.
;   - rdx: Length of the string in bytes.
; Behavior:
;   Sets up the write system call and executes it.
; Returns:
;   The number of bytes written (or an error) in RAX.
print_string:
    mov rax, SYS_WRITE  ; Load write syscall number (1) into RAX.
    syscall             ; Write the string (using RDI, RSI, and RDX).
    ret                 ; Return to the caller.

; ----------------------------------------------------------------------------
; Function: open_file
; Purpose:
;   Opens a file in read-only mode.
; Inputs:
;   - rsi: Pointer to the null-terminated filename string.
; Behavior:
;   Uses the openat system call to open the file with AT_FDCWD (current directory)
;   and O_RDONLY (read-only mode). Returns a file descriptor in RAX.
; Returns:
;   - RAX: A non-negative file descriptor if successful, or a negative value if an error occurs.
open_file:
    mov rax, SYS_OPENAT ; Load openat syscall number (257) into RAX.
    mov rdi, AT_FDCWD   ; RDI: Use the current directory (AT_FDCWD, -100).
    mov rdx, O_RDONLY   ; RDX: Set file access mode to read-only.
    mov r10, 0          ; R10: Unused for read-only; set to 0.
    syscall             ; Execute openat; file descriptor returned in RAX.
    ret                 ; Return to the caller.

; ----------------------------------------------------------------------------
; Function: close_file
; Purpose:
;   Closes an open file descriptor.
; Inputs:
;   - rdi: The file descriptor to close.
; Behavior:
;   Calls the close system call to release the file.
; Returns:
;   The result of the close operation in RAX.
close_file:
    mov rax, SYS_CLOSE  ; Load close syscall number (3) into RAX.
    syscall             ; Execute the close syscall.
    ret                 ; Return to the caller.

; ----------------------------------------------------------------------------
; Function: read_from_file
; Purpose:
;   Reads data from a file into a buffer.
; Inputs:
;   - rdi: File descriptor from which to read.
;   - rsi: Pointer to the buffer where data should be stored.
;   - rdx: Number of bytes to read (usually the size of the buffer).
; Behavior:
;   Executes the read system call and returns the number of bytes read.
; Returns:
;   - RAX: The number of bytes read (0 indicates end-of-file; negative indicates an error).
read_from_file:
    mov rax, SYS_READ   ; Load read syscall number (0) into RAX.
    syscall             ; Execute the read syscall.
    ret                 ; Return with the read count in RAX.

; ----------------------------------------------------------------------------
; Function: write_to_stdout
; Purpose:
;   Writes data from a buffer to standard output (stdout).
; Inputs:
;   - rsi: Pointer to the buffer containing the data.
;   - rdx: Number of bytes to write.
; Behavior:
;   Sets the file descriptor for stdout (1) and makes the write system call.
; Returns:
;   The result of the write operation in RAX.
write_to_stdout:
    mov rdi, 1          ; Set file descriptor to 1 (stdout).
    mov rax, SYS_WRITE  ; Load write syscall number (1) into RAX.
    syscall             ; Execute the syscall to write the data.
    ret                 ; Return to the caller.

; ----------------------------------------------------------------------------
; Function: check_arguments
; Purpose:
;   Validates that at least one command-line argument (the filename) is provided.
; Behavior:
;   The argument count is located at the top of the stack when the program starts.
;   If fewer than 2 arguments are found (program name + filename), an error message
;   is printed to stderr and the program exits.
; Inputs:
;   - The stack pointer (rsp) initially points to argc.
; Returns:
;   Continues if argument count is sufficient; otherwise, it terminates the program.
check_arguments:
    mov rax, [rsp]      ; Retrieve argc (argument count) from the stack.
    cmp rax, 2          ; Compare argc with 2 (program name and at least one extra argument).
    jge .args_ok        ; If argc >= 2, continue execution.
    ; Not enough arguments: print error message to stderr.
    mov rdi, 2          ; Set file descriptor to 2 (stderr).
    mov rsi, open_err_msg   ; Point to the open error message.
    mov rdx, open_err_msg_len   ; Message length.
    call print_string   ; Write the error message.
    mov rdi, 1          ; Use 1 as the error exit code.
    call exit_program   ; Terminate the program.
.args_ok:
    ret                 ; If arguments are valid, return to the caller.

; ----------------------------------------------------------------------------
; _start: Entry point of the program.
; Purpose:
;   Implements the main logic:
;     1. Verify command-line arguments.
;     2. Open the specified file.
;     3. Loop: read chunks from the file and write them to stdout.
;     4. Handle errors by printing messages and exiting.
_start:
    ; Check if the user provided a filename.
    call check_arguments

    ; Retrieve the pointer to the filename:
    ; The stack layout on entry is as follows:
    ;   [rsp]       : argc (number of command-line arguments)
    ;   [rsp+8]     : pointer to argv[0] (program name)
    ;   [rsp+16]    : pointer to argv[1] (filename)
    mov rsi, [rsp+16] ; Load the pointer to the filename into RSI.

    ; Attempt to open the file using the provided filename.
    call open_file
    ; RAX now holds the file descriptor, or a negative error code.
    cmp rax, 0
    js .open_error    ; If the value in RAX is negative, jump to the error handler.
    mov r12, rax      ; Save the valid file descriptor in R12 for later use.

.read_loop:
    ; Read a chunk of data from the file.
    ; Inputs for the read_from_file function:
    ;   - rdi: File descriptor (in R12)
    ;   - rsi: Pointer to our buffer (address of 'buffer')
    ;   - rdx: Maximum number of bytes to read (buffer_size)
    mov rdi, r12         ; Set RDI to our file descriptor.
    mov rsi, buffer      ; Set RSI to point to the buffer.
    mov rdx, buffer_size ; Set RDX to the size of our buffer.
    call read_from_file  ; Call the function to read from the file.
    
    ; Check the result of the read operation.
    cmp rax, 0
    je .close_file       ; If RAX is 0, end-of-file reached; jump to file closure.
    js .read_error       ; If RAX is negative, a read error occurred; jump to error handler.
    mov rbx, rax         ; Store the number of bytes read in RBX.

    ; Write the read data to standard output.
    mov rsi, buffer      ; RSI now points to the buffer.
    mov rdx, rbx         ; RDX is the number of bytes to write.
    call write_to_stdout ; Write the buffer contents to stdout.
    jmp .read_loop       ; Loop back to read the next chunk.

.close_file:
    ; After reading the entire file, close the file descriptor.
    mov rdi, r12         ; Move the file descriptor back into RDI.
    call close_file      ; Close the file.
    mov rdi, 0           ; Prepare exit code 0 (success).
    call exit_program    ; Exit the program.

.open_error:
    ; Error handling for failure in opening the file.
    mov rdi, 2          ; Set file descriptor to stderr.
    mov rsi, open_err_msg   ; Point to the error message.
    mov rdx, open_err_msg_len ; Set message length.
    call print_string   ; Print the error message.
    mov rdi, 1          ; Use exit code 1 to indicate an error.
    call exit_program   ; Exit the program.

.read_error:
    ; Error handling for failure during file read.
    mov rdi, 2          ; Set file descriptor to stderr.
    mov rsi, read_err_msg   ; Point to the read error message.
    mov rdx, read_err_msg_len ; Set message length.
    call print_string   ; Print the error message.
    mov rdi, 1          ; Use exit code 1 to indicate an error.
    call exit_program   ; Exit the program.
