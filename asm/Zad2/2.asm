; Założenie programu jest takie: zamieniamy input na inta i umieszczamy go w rejestrze. 
; Następnie Dokonujemy zmiany inta trzymanego w rejestrze na jego reprezenatcje dziesiętną,
; która jest możliwa do wyświetlenia (przy użyciu BCD). Program sam w sobie nie ma sensu,
; ale daje pewne możliwości. Wyobraźmy sobie, że chcemy napisać prosty program, który 
; pobiera od użytkownika inta i chce pomnożyć go przez 2. Wtedy potrzebujemy wykonać 
; następujące czynności: zmienić input na inta, pomnożyć go przez 2, zmienić inta na output.
; Widzimy, że 
global _start


section .data
msg db "Input number: "
msg_size equ $-msg
msg2 db "You wrote: "
msg2_size equ $-msg2
user_output db '     ', 0xA

section .bss
user_input resb 16

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

int_to_dec:
    ; w edi adres bufora wyjściowego, liczba do skonwertowania w eax (Tak naprawdę to w ax bo ma tylko 16 bitów)
    push edi
    push ecx
    push edx
    add edi, 4
    mov ecx, 10
    loop2:
        mov edx, 0 ; reszta będzie w edx
        div ecx ; dzielimy eax przez 10 reszta jest w edx , wynik w eax
        add edx, '0' ; w edx mamy zapisaną cyfrę w BCD, zamieniamy ją na numer w ASCII
        mov [edi], byte dl
        dec edi
        cmp eax, 0
        jne loop2
    end_loop2:
    pop ecx
    pop ebx
    pop edi
    ret

dec_to_dec:
    ; w esi adres bufora wejściowego, w edi adres bufora wyjściowego
    mov esi, user_input
    mov edi, user_output
    call dec_to_int
    call int_to_dec
    ret

_start:
    call first_message
    call get_user_input
    call dec_to_dec
    call second_message
    mov eax, 4
    mov ebx, 1
    mov ecx, user_output
    mov edx, 6
    int 0x80
    call exit