global _start

section .data
msg db "Input number: "
msg_size equ $-msg
msg2 db "You wrote: "
msg2_size equ $-msg2
list db '0123456789ABCDEF'
user_output db '0x12345678', 0xA


section .bss
user_input resb 16
converted_number: resb 4



section .text

first_message:
    ; Wyświetlamy "Input number: "
    mov edx, msg_size ; ustawiamy liczbę wyświetlanych bajtów
    mov ebx, 1 ; stdout
    mov ecx, msg    
    mov eax, 4 ; 4 = write
    int 0x80
    ret

second_message:
    ; Wyświetlamy "You wrote: "
    mov edx, msg2_size ; ustawiamy liczbę wyświetlanych bajtów
    mov ebx, 1 ; stdout
    mov ecx, msg2    
    mov eax, 4 ; 4 = write
    int 80h
    ret

get_user_input:
    ; Sczytujemy input
    mov edx, 16 
    mov ebx, 0 ; stdin
    mov ecx, user_input ; zapisujemy input do user_input
    mov eax, 3 ; 3 = read
    int 80h
    ret
exit:
    mov eax,1
    mov ebx,0
    int 0x80

dec_to_int:
    ; w esi ma adres bufora wejściowego, w eax zwracamy liczbę
    push esi
    push ebx
    push ecx
    mov ecx,10
    mov ebx, 0
    mov eax,0
    loop1:
        mov ebx, [esi] ; w ebx jest literaz z esi
        and ebx, 0xFF
        cmp bl, '0'
        jb end_loop1
        cmp bl, '9'
        ja end_loop1
        sub ebx, '0'
        mul ecx
        add eax, ebx
        inc esi
        jmp loop1
    end_loop1:
    pop ecx
    pop ebx
    pop esi
    ret

int_to_hex:
    ; w edi adres bufora wyjściowego, w eax liczba do skonwertowania
    push edi
    push ebx
    push ecx
    add edi,9
    mov ebx, eax
    mov ecx, 8
    loop2:
        mov eax, 0xF
        and eax, ebx
        movzx eax, byte[list + eax]
        mov [edi], al
        shr ebx, 4
        dec edi
        dec ecx
        cmp ecx, 0 
        jne loop2
    end_loop2:

    pop ecx
    pop ebx
    pop edi
    ret

dec_to_hex:
    ; w esi jest adres tekstu wejściowego, a w edi adres bufora wyjściowego
    mov esi, user_input
    mov edi, user_output
    call dec_to_int
    call int_to_hex
    ret
_start:
    call first_message
    call get_user_input
    call dec_to_hex
    call second_message
    mov eax, 4
    mov edx,11
    mov ebx,1
    mov ecx, user_output
    int 0x80
    call exit