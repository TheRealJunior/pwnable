#!/bin/bash
rm out.o
nasm -felf64 read.s
ld --omagic read.o -o out.o

rm read.o
