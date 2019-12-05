@ rm /tmp/pe.s; vi /tmp/pe.s; as /tmp/pe.s -o /tmp/pe.o; ld /tmp/pe.o -o /tmp/pe; /tmp/pe
.text
.global _start

@ _start:
@     mov r0, #1              @ stdout
@     add r1, pc, #16         @ address of the string
@     mov r7, #4              @ syscall for 'write'
@     swi #0                  @ software interrupt

_start:
@  print _in to screen
    ldr r0, =_in
    mov r1, #25
    bl _print


@ call sys_upper
    mov r7, #223
    ldr r0, =_in
    ldr r1, =_out
    swi #0

@ print out to screen
    ldr r0, =_out
    mov r1, #25
    bl _print

@ try writing to text section of kernel
    bl _try_write_text


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


.data
_in:
    .string "hey there in lowercase\n"          @ our string, NULL terminated

_out:
    .skip 40 @ just placeholder

_text:
    .word 0x80008000
