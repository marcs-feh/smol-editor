#!/usr/bin/env sh

cc=gcc
cflags='-O2 -fPIE -fno-strict-aliasing'

set -xe

$cc $cflags -c terminal/term_linux.c -o terminal/term_linux.o
odin build .

