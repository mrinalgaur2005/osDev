org 0x7C00
bits 16

%define ENDL 0x0D ,0x0A

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

    mov si,msg_hello
    call puts
    hlt

halt:
    jmp halt


msg_hello:db 'Hello World lalal',ENDL,0

times 510-($-$$) db 0
dw 0xAA55