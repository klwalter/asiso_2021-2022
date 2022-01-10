        global      _start

        section     .data
msg     db          "Hello, World!!!", 0xA ; msg = Hello, World!!! + koniec linii (W ASCII)

        section     .text
_start: 
        mov         rdx, 16 ; ustaw arg2-size na 16
        mov         rdi, 1 ; ustaw arg0-file descriptor na standard output
        mov         rsi, msg ; ustaw arg1-*char na message
        mov         rax, 1 ; system call write
        syscall
	mov	    rdi, 0;
        mov         rax, 60 ; system call exit
        syscall
