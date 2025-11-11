org 0x7C00
bits 16

start:
    jmp main 
;prints string to the screen

puts:
    push si;
    push ax;

loop:
    


main:
    ;data segment
    mov ax,0
    mov ds,ax
    mov es,ax

    ;stack seg
    mov ss,ax
    mov sp,0x7C00
    hlt

halt:
    jmp halt

times 510-($-$$) db 0
dw 0AA55h