global _start

section .data
msg db "Input number: "
msg_size equ $-msg
mes db '0'
endline db 0xa

section .bss
user_input1 resb 10
user_input2 resb 10
result1 resb 4
result2 resb 4

section .text

first_message:
    ; Wyświetlamy "Input number: "
    mov edx, msg_size ; ustawiamy liczbę wyświetlanych bajtów
    mov ebx, 1 ; stdout
    mov ecx, msg    
    mov eax, 4 ; 4 = write
    int 0x80
    ret

get_user_input1:
    ; Sczytujemy input
    mov edx, 16 
    mov ebx, 0 ; stdin
    mov ecx, user_input1 ; zapisujemy input do user_input
    mov eax, 3 ; 3 = read
    int 80h
    ret

get_user_input2:
    ; Sczytujemy input
    mov edx, 16 
    mov ebx, 0 ; stdin
    mov ecx, user_input2 ; zapisujemy input do user_input
    mov eax, 3 ; 3 = read
    int 80h
    ret

dec_to_int:

    ; w esi ma adres bufora wejściowego, w eax zwracamy liczbę
    push rsi
    push rbx
    push rcx
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
    pop rcx
    pop rbx
    pop rsi
    ret


division:
    ; wynik dzielenia result1/result2 w rbx, reszta w rcx
    push rax
    mov rcx, 0 ; reszta
    mov rbx, 0 ; wynik
    mov eax, [result1] ; dzielna
    mov edx, [result2] ; dzielnik
    mov r9, 64; licznik
    div_loop:
        cmp r9, 0 
        je end_div_loop
        dec r9
        mov rdi, rax 
        shr rdi, 63 ; edi = największy bit rax
        shl rax, 1 ; przesuwamy rax w lewo
        shl rcx, 1 ; mnożymy rcx przez 2
        shl rbx, 1 
        add rcx, rdi ; dodajemy największy bit do reszty
        ; w tym miejscu przesunęliśmy największy bit rax do najmniejszego bitu rcx
        cmp rcx, rdx
        jb div_loop
        add rbx, 1
        sub rcx, rdx
        jmp div_loop
    end_div_loop:
    pop rax
    ret

print:
    ; printuje liczbę zapisaną w rax
    push rdi
    push rax
    push rcx
    push rdx
    push rsi
    push rbx
    xor rbx, rbx
    mov rcx, 10
    print_loop: ; wyoisujemy liczby w odwrotnej kolejności
        cmp rax, 0
        je print_loop2
        xor rdx, rdx
        div rcx
        add rdx, '0'
        push rdx
        inc rbx
        jmp print_loop
    print_loop2:
        cmp rbx, 0
        je print_end2
        dec rbx
        pop rdx
        mov [mes], dl
        mov rax, 1
        mov rdi, 1
        mov rsi, mes
        mov rdx, 1
        syscall
        jmp print_loop2
    print_end2:
    mov rax, 1
    mov rdi, 1
    mov rsi, endline
    mov rdx,1
    syscall

    pop rbx
    pop rsi
    pop rdx
    pop rcx
    pop rax
    pop rdi
    ret
_start:
    mov rbx, 0 ; wynik dzielenia
    mov rcx, 0 ; reszta z dzielenia

    ; pobieramy pierwszą liczbę i zapisujemy w result1
    call first_message
    call get_user_input1

    mov esi, user_input1
    call dec_to_int
    mov [result1], eax

    ; pobieramy pierwszą liczbę i zapisujemy w result2
    call first_message
    call get_user_input2

    mov esi, user_input2
    call dec_to_int
    mov [result2], eax
break:
    call division
    mov rax, rbx
    call print
    mov rax, rcx
    call print

    mov rax,60
    mov rdi,rbx
    syscall