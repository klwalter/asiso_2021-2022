global _start
extern printf

section .data
number1 dq 2.7182810
number2 dq 1.0
number3 dq 2.0
number4 dq 5.0
msg db "%e", 10, 0

section .bss
lnx: resq 1 ; 64 bity
ex: resq 1
sinhx: resq 1
sinh1x: resq 1

section .text

ln:
    fld1; st0 = 1, 
    fldl2e ; st0 = log_2(e), st1 = 1 
    fdivp ; st0 = 1/log_2(e)
    fld qword [number1]; st0 = number, st1 = 1/log_2(e) 
    fyl2x ; st0 = number, st1 = 1/log_2(e) * log_2(number) = ln(x)
    fstp qword [lnx]
    ret

e:
    fld qword [number2] ; st0 = number
    fldl2e  ; st1 = number st0 = log2(e)
    fmulp   st1, st0 ; st0 = number*log2(e)
    fld1    ; st0 = 1 st1 = number*log2(e)
    fld     st1 ; st0 = number*log2(e), st1=1, st2=number*log2(e)
    fprem   ; st0 = partial reminder number*log2(e)/1 st1 = 1 st2 = number*log2(e)
    f2xm1   ; st0 = 2^(partial reminder number*log2(e)/1)-1 st1 = 1 st2 = number*log2(e)
    faddp   st1, st0    ; st0 = 2^(partial reminder number*log2(e)/1) st1 = number*log2(e)
    fscale ; st0*2^st1
    fstp    st1
    fstp qword [ex]
    ret

sinh:
    fld qword [number3] ; st0 = number
    fldl2e  ; st1 = number st0 = log2(e)
    fmulp   st1, st0 ; st0 = number*log2(e)
    fld1    ; st0 = 1 st1 = number*log2(e)
    fld     st1 ; st0 = number*log2(e), st1=1, st2=number*log2(e)
    fprem   ; st0 = partial reminder number*log2(e)/1 st1 = 1 st2 = number*log2(e)
    f2xm1   ; st0 = 2^(partial reminder number*log2(e)/1)-1 st1 = 1 st2 = number*log2(e)
    faddp   st1, st0    ; st0 = 2^(partial reminder number*log2(e)/1) st1 = number*log2(e)
    fscale ; st0*2^st1
    fstp    st1

    fld1 ; st0 = 1, st1 = e^x
    fdiv st0, st1 ; st0 = e^-x, st1 = e^x
    fsubp ; st0 = e^x - e^-x
    fld1 ; st0 = 1, st = e^x - e^-x
    fld1 ; st0 = 1, st1 = 1, st2 = e^x - e^-x
    faddp ; st0 = 2, st1 = e^x - e^-x
    fdivp ; st0 = (e^x - e^-x)/2
    fstp qword [sinhx]
    ret

sinh1:
    fld1; st0 = 1, 
    fldl2e ; st0 = log_2(e), st1 = 1 
    fdivp ; st0 = 1/log_2(e)
    fld1 ; st0 = 1, st1 = 1/log_2(e)
    fld qword [number4]
    fld qword [number4]
    fmulp ; st0 = number^2, st1 = 1, st2 = 1/log_2(e)
    faddp ; st0 = number^2 + 1, st1 = 1/log_2(e)
    fsqrt ; st0 = sqrt(number^2 + 1) st1 = 1/log_2(e)
    fld qword [number4] ; st0 = number, st1 = sqrt(number^2 + 1) st2 = 1/log_2(e)
    faddp ; st0 = numer + sqrt(number^2 + 1) st1 = 1/log_2(e)
    fyl2x ; st0 = sqrt(number^2 + 1), st1 = 1/log_2(e) * log_2(number + sqrt(number^2 + 1)) = ln(number + sqrt(number^2 + 1))
    fstp qword [sinh1x]
    ret

_start:
    call ln
    call e
    call sinh
    call sinh1

    push dword [lnx + 4]
    push dword [lnx]
    push msg
    call printf

    push dword [ex + 4]
    push dword [ex]
    push msg
    call printf

    push dword [sinhx + 4]
    push dword [sinhx]
    push msg
    call printf

    push dword [sinh1x + 4]
    push dword [sinh1x]
    push msg
    call printf
