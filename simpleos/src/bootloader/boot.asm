org 0x7c00
bits 16

jmp short main
nop

bdb_oem: db "MSWIN4.1"
bdb_bytes_per_sector: dw 512
bdb_sectors_per_cluster: db 1
bdb_reserved_sectors: dw 1
bdb_fat_count: db 2
bdb_dir_entries_count: dw 0e0h
bdb_total_sectors: dw 2880
bdb_media_descriptor_type: db 0f0h
bdb_sectors_per_fat: dw 9
bdb_sectors_per_track: dw 18
bdb_heads: dw 2
bdb_hidden_sectors: dd 0
bdb_large_sector_count dd 0

ebr_drive_number: db 0
db 0
ebr_signature: db 29h
ebr_volume_id: db 12h,34h,56h,78h
ebr_volume_label: db "SIMPLEOS   "
ebr_system_id: db "FAT12   "

main:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7c00

    mov [ebr_drive_number], dl
    mov ax, 1
    mov cl, 1
    mov bx, 0x7e00
    call disk_read

    mov si, os_boot_msg
    call print

    hlt 

halt:
    jmp halt

; input: lab index in ax
; cx [bits 0-5]: sector number
; cx [bits 6-15]: cylinder number
; dh: head
lba_to_chs:
    push ax
    push dx

    ; sector: (lba % sectors per track) + 1
    xor dx, dx
    div word [bdb_sectors_per_track] 
    inc dx ; sector
    mov cx, dx

    ; head: (lab / sectors per track) % number of heads
    ; cylinder: (lba / sectors per track) / number of heads
    xor dx, dx
    div word [bdb_heads]
    mov dh, dl ; head
    mov ch, al
    shl ah, 6
    or cl, ah ; cylinder

    pop ax
    mov dl, al
    pop ax

    ret

disk_read:
    push ax
    push bx
    push cx
    push dx
    push di

    call lba_to_chs

    mov ah, 02h
    mov di, 3 ; counter

disk_read_retry:
    stc
    int 13h
    jnc done_disk_read

    call disk_read_reset

    dec di
    test di, di
    jnz disk_read_retry

fail_disk_read:
    mov si, disk_read_failure
    call print
    hlt
    jmp halt

disk_read_reset:
    pusha

    mov ah, 0
    stc
    int 13h
    jc fail_disk_read

    popa
    ret

done_disk_read:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    ret

print:
    push si
    push ax
    push bx

print_loop:
    lodsb
    or al, al
    jz done_print

    mov ah, 0x0e
    mov bh, 0
    int 0x10

    jmp print_loop

done_print:
    pop bx
    pop ax
    pop si

    ret

os_boot_msg: db "simpleos has booted!",0x0d,0x0a,0
disk_read_failure: db "Failed to read disk!",0x0d,0x0a,0
times 510-($-$$) db 0
dw 0aa55h
