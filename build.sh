#!/usr/bin/env sh

cc=gcc
cflags='-O2 -fPIE -fno-strict-aliasing'

set -xe

$cc $cflags -c terminal/tty_linux.c -o terminal/tty_linux.o
odin build .

