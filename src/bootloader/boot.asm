org 0x7C00
bits 16

%define ENDL 0x0D ,0x0A

;FAT12 header

jmp short start
nop

bdb_oem: db 'MSWIN4.1'
bdb_bytes_per_sector: dw 512
bdb_sectors_per_cluster: db 1
bdb_reserved_sectors: dw 1
bdb_fat_count: db 2
bdb_dir_Entries_count: dw 0E0h
bdb_total_sectors: dw 2880

;BIOS Parameter Block (BPB)
bdb_media_descriptor_type: db 0F0h
bdb_sectors_per_fat:      dw 9
bdb_sectors_per_track:    dw 18
bdb_heads:                dw 2
bdb_hidden_sectors:       dd 0
bdb_large_sector_count:   dd 0

;Extended Boot Record (EBR)
ebr_drive_number:         db 0
                          db 0          ; reserved byte
ebr_signature:            db 29h
ebr_volume_id:            db 12h, 34h, 56h, 78h
ebr_volume_label:         db 'NANOBYTE OS'
ebr_system_id:            db 'FAT12   '


start:
    jmp main 
;prints string to the screen

puts:
    push si
    push ax


.loop:
    lodsb ;load the next char
    or al,al ;verifies the next char null status
    jz .done

    mov ah,0x0e
    mov bh,0
    int 0x10
    jmp .loop

.done:
    pop ax
    pop si
    ret


main:
    ;data segment
    xor ax,ax
    mov ds,ax
    mov es,ax

    ;stack seg
    mov ss,ax
    mov sp,0x7C00 ;stack now going downwards

    ;read something
    ;BIOS should set DL to drive number
    mov[ebr_drive_number],dl
    mov ax,1;second sector of disc
    mov cl,1
    mov bx,0x7E00;data should be after the bootloader
    call disk_read



    mov si,msg_hello
    call puts
    cli 
    hlt

floppy_err:
    mov si,msg_readf_failed
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah,0
    int 16h
    jmp 0FFFFh:0 ;beginning of bios

halt:
    cli
    hlt

;stores ax(LBA add) in cx[bits 0-5]:sector num
                    ;  cx[bits 6-15]:cylinders
                    ;  dh: head
lba_to_chs: 

    push ax
    push dx

    xor dx,dx
    div word [bdb_sectors_per_track] ;ax = divison ans
                                    ; dx = remainder

    inc dx ;val of sector 
    mov cx,dx

    xor dx,dx
    div word [bdb_heads]

    mov dh,dl
    mov ch,al
    shl ah,6
    or cl,ah ;put upper 2 bits of cylinder in CL

    pop ax
    mov al,dl ;restoring DL
    pop ax
    ret


;reads from the disk 
;Params:
;
;   ax:LBA add
;   cl:no of sectors to read
;   dl:drive no
;   es:bx : mem add where to store the read data
;
;
disk_read:
    push ax
    push bx
    push cx
    push dx
    push di



    push cx
    call lba_to_chs
    pop ax

    mov ah,02h
    mov di,3


.retry:
    pusha
    stc ;set carry
    int 13h
    jnc .done
    popa
    call disk_read

    dec di;
    test di,di
    jnz .retry

.fail:
    jmp floppy_err


.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

disk_reset:
    pusha
    mov ah,0
    stc
    int 13h
    jc floppy_err
    popa
    ret



msg_hello:db 'Hello World lalal',ENDL,0
msg_readf_failed:db 'Read failed',ENDL,0

times 510-($-$$) db 0
dw 0xAA55