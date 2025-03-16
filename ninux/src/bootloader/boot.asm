org 0x7c00           ; Boot sector load address
bits 16              ; Generate 16-bit real mode code

jmp short boot_main  ; Jump to boot_main routine, skipping BPB/EBR data
nop                  ; No operation (alignment/padding)

; ---------------------------------------------------------------------------
; BIOS Parameter Block (BPB)
; Contains disk geometry and filesystem parameters.
; ---------------------------------------------------------------------------
oem_name:             db 'MSWIN4.1'         ; OEM identifier string
bytes_per_sector:     dw 512                ; Bytes per disk sector
sectors_per_cluster:  db 1                  ; Sectors per cluster (allocation unit)
reserved_sector_cnt:  dw 1                  ; Number of reserved sectors (includes boot sector)
num_fats:             db 2                  ; Number of FAT copies on disk
root_entry_cnt:       dw 0e0h               ; Maximum number of root directory entries
total_sectors16:      dw 2880               ; Total number of sectors (if < 65536)
media_descriptor:     db 0f0h               ; Media descriptor (identifies storage media)
fat_size16:           dw 9                  ; Sectors per FAT
sectors_per_track:    dw 18                 ; Sectors per track (disk geometry)
num_heads:            dw 2                  ; Number of disk heads (disk geometry)
hidden_sectors:       dd 0                  ; Number of hidden sectors preceding the partition
total_sectors32:      dd 0                  ; Total sectors (32-bit field; unused here)

; ---------------------------------------------------------------------------
; Extended Boot Record (EBR)
; Provides additional boot information.
; ---------------------------------------------------------------------------
drive_number:         db 0                   ; BIOS drive number (0 = floppy)
reserved_byte:        db 0                   ; Reserved byte (should be zero)
boot_signature:       db 29h                 ; Extended boot signature (validates EBR)
volume_id:            db 12h, 34h, 56h, 78h  ; Volume serial number
volume_label:         db 'NINUX      '       ; Volume label (padded to 11 bytes)
filesystem_type:      db 'FAT12   '          ; Filesystem type string

; ---------------------------------------------------------------------------
; Bootloader Main Code
; ---------------------------------------------------------------------------
boot_main:
    ; Initialize data, extra, and stack segments for flat memory addressing.
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7c00           ; Set up the stack pointer

    ; Display boot message on screen.
    mov si, boot_message
    call print_string

    ; -----------------------------------------------------------------------
    ; Calculate root directory starting LBA:
    ;   lba = reserved_sector_cnt + (fat_size16 * num_fats)
    ; -----------------------------------------------------------------------
    mov ax, [fat_size16]     ; Load FAT size (in sectors)
    mov bl, [num_fats]       ; Load number of FAT copies
    xor bh, bh               ; Clear BH (upper byte of BX)
    mul bx                   ; Multiply: ax = fat_size16 * num_fats
    add ax, [reserved_sector_cnt]  ; Add reserved sectors to get root dir lba
    push ax                  ; Save root directory lba on stack

    ; -----------------------------------------------------------------------
    ; Calculate number of sectors for root directory:
    ;   sectors_needed = (root_entry_cnt * 32) / bytes_per_sector (rounded up)
    ; -----------------------------------------------------------------------
    mov ax, [root_entry_cnt]
    shl ax, 5                ; Multiply by 32 (each directory entry is 32 bytes)
    xor dx, dx
    div word [bytes_per_sector] ; Divide by bytes_per_sector (512)
    test dx, dx
    jz root_dir_sectors_calculated
    inc ax                   ; If remainder exists, add one extra sector

root_dir_sectors_calculated:
    mov cl, al               ; Number of sectors to read for the root directory
    pop ax                   ; Retrieve the root directory lba from stack
    mov dl, [drive_number]   ; Set drive number for disk read
    mov bx, disk_buffer      ; Destination buffer for disk read
    call disk_read_sector    ; Read the root directory sector into disk_buffer

    xor bx, bx
    mov di, disk_buffer      ; DI points to the first directory entry

    ; -----------------------------------------------------------------------
    ; Kernel File Search:
    ; Compare each 32-byte directory entry to the expected kernel filename.
    ; -----------------------------------------------------------------------
kernel_search:
    mov si, kernel_filename  ; SI points to expected 11-byte kernel filename
    mov cx, 11               ; Compare 11 characters (8.3 filename)
    push di                ; Save current directory entry pointer
    repe cmpsb           ; Compare directory entry with filename
    pop di               ; Restore pointer
    je kernel_found      ; If equal, kernel file is found

    add di, 32           ; Move to next directory entry (each is 32 bytes)
    inc bx               ; Increment entry counter
    cmp bx, [root_entry_cnt]
    jl kernel_search     ; Continue search if not at end

    ; Kernel file not found; print error and halt.
    jmp kernel_not_found

kernel_not_found:
    mov si, msg_kernel_not_found
    call print_string
    hlt
    jmp boot_halt_loop

kernel_found:
    ; -----------------------------------------------------------------------
    ; Retrieve starting cluster of the kernel file.
    ; The starting cluster number is at offset 26 in the directory entry.
    ; -----------------------------------------------------------------------
    mov ax, [di+26]
    mov [kernel_start_cluster], ax

    ; -----------------------------------------------------------------------
    ; Load FAT table sector containing the cluster chain information.
    ; The FAT begins at lba = reserved_sector_cnt.
    ; -----------------------------------------------------------------------
    mov ax, [reserved_sector_cnt]
    mov bx, disk_buffer 
    mov cl, [fat_size16]
    mov dl, [drive_number]
    call disk_read_sector

    ; -----------------------------------------------------------------------
    ; Prepare memory location for loading the kernel.
    ; Kernel will be loaded at kernel_load_segment:kernel_load_offset.
    ; -----------------------------------------------------------------------
    mov bx, kernel_load_segment
    mov es, bx
    mov bx, kernel_load_offset

    ; -----------------------------------------------------------------------
    ; Load the kernel by following its cluster chain from the FAT.
    ; -----------------------------------------------------------------------
kernel_load_loop:
    mov ax, [kernel_start_cluster]
    add ax, 31              ; Adjust cluster number to compute corresponding lba
    mov cl, 1               ; Set to read one sector
    mov dl, [drive_number]
    call disk_read_sector   ; Read sector corresponding to the current cluster

    add bx, [bytes_per_sector] ; Advance the load pointer by one sector

    ; -----------------------------------------------------------------------
    ; Get next cluster from FAT:
    ;   Calculate FAT entry offset: (kernel_start_cluster * 3) / 2 for FAT12.
    ; -----------------------------------------------------------------------
    mov ax, [kernel_start_cluster]
    mov cx, 3
    mul cx                ; Multiply cluster number by 3
    mov cx, 2
    div cx                ; Divide by 2 to get offset into FAT table

    mov si, disk_buffer
    add si, ax            ; SI now points to the FAT entry
    mov ax, [ds:si]       ; Load FAT entry (12 bits relevant)

    or dx, dx
    jz kernel_even_cluster

kernel_odd_cluster:
    shr ax, 4             ; For odd-numbered entries, shift right 4 bits
    jmp kernel_next_cluster

kernel_even_cluster:
    and ax, 0x0fff        ; For even-numbered entries, mask to 12 bits

kernel_next_cluster:
    cmp ax, 0x0ff8        ; Check for end-of-chain marker (>= 0x0ff8)
    jae kernel_load_done
    mov [kernel_start_cluster], ax  ; Update with next cluster number
    jmp kernel_load_loop

kernel_load_done:
    ; -----------------------------------------------------------------------
    ; Kernel loading done.
    ; Jump to the kernel’s entry point at kernel_load_segment:kernel_load_offset.
    ; -----------------------------------------------------------------------
    mov dl, [drive_number]
    mov ax, kernel_load_segment
    mov ds, ax
    mov es, ax
    jmp kernel_load_segment:kernel_load_offset
    hlt

boot_halt_loop:
    jmp boot_halt_loop

; ---------------------------------------------------------------------------
; Disk Read Routines (Prefix: disk_)
; ---------------------------------------------------------------------------

; Convert a linear block address (lba) to Cylinder-Head-Sector (chs) format.
disk_convert_lba_to_chs:
    push ax
    push dx

    xor dx, dx
    div word [sectors_per_track]   ; Divide lba by sectors per track; remainder = sector
    inc dx                         ; Sectors are 1-based; adjust remainder
    mov cx, dx                   ; Save sector number in cx

    xor dx, dx
    div word [num_heads]           ; Divide to compute head and cylinder values
    mov dh, dl                   ; DH = head number
    mov ch, al                   ; CH = lower part of cylinder number
    shl ah, 6
    or cl, ah                    ; Merge with high bits of cylinder number

    pop ax
    mov dl, al                   ; (Preserve drive number if needed)
    pop ax
    ret

; Read a disk sector using BIOS interrupt 13h.
disk_read_sector:
    push ax
    push bx
    push cx
    push dx
    push di

    call disk_convert_lba_to_chs    ; Convert lba to chs addressing for BIOS

    mov ah, 02h                ; BIOS function: Read Sector(s)
    mov di, 3                  ; Set retry counter to 3

disk_read_retry:
    stc
    int 13h
    jnc disk_sector_read_done  ; If no error, jump to done

    call disk_reset            ; On error, attempt disk reset

    dec di
    test di, di
    jnz disk_read_retry        ; Retry if attempts remain

disk_read_fail:
    mov si, msg_read_failure
    call print_string
    hlt
    jmp boot_halt_loop

disk_sector_read_done:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Reset the disk system after a read failure.
disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc disk_read_fail
    popa
    ret

; ---------------------------------------------------------------------------
; Print Routines (Prefix: print_)
; ---------------------------------------------------------------------------

; Prints a null-terminated string using BIOS interrupt 10h (teletype output).
print_string:
    push si
    push ax
    push bx

print_loop:
    lodsb                  ; Load next character into al
    or al, al              ; Check if character is zero (string terminator)
    jz print_done
    mov ah, 0x0e           ; BIOS teletype output function
    mov bh, 0
    int 10h                ; Display the character
    jmp print_loop

print_done:
    pop bx
    pop ax
    pop si
    ret

; ---------------------------------------------------------------------------
; Boot Messages and Data Definitions
; ---------------------------------------------------------------------------
boot_message:          db 'Loading...', 0x0d, 0x0a, 0           ; Boot message with CR/LF termination
msg_read_failure:      db 'Failed to read disk!', 0x0d, 0x0a, 0     ; Error message for disk read failure
kernel_filename:       db 'KERNEL  BIN'                        ; Expected kernel filename (11 bytes: 8.3 format)
msg_kernel_not_found:  db 'KERNEL.BIN not found!', 0x0d, 0x0a, 0    ; Error if kernel file is missing
kernel_start_cluster:  dw 0                                   ; Variable to hold the kernel file’s starting cluster

; Define where the kernel should be loaded in memory.
kernel_load_segment   equ 0x2000
kernel_load_offset    equ 0

; ---------------------------------------------------------------------------
; Pad boot sector to 510 bytes and add boot signature.
; ---------------------------------------------------------------------------
times 510 - ($ - $$) db 0   ; Fill remaining bytes with zeros
dw 0aa55h                  ; Boot sector signature (0xAA55)

disk_buffer:              ; Buffer for disk sector reads
