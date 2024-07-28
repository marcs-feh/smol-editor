#pragma once

#include "terminal.hpp"
#include "sequences.hpp"

#include "core/core.hpp"
#include <cstdio>
#include <termios.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/termios.h>

namespace term {

constexpr i32 stdout_fd = 1;

void enable_raw_mode(){
	auto fd = stdout_fd;
	struct termios tio {};
	i32 err = 0;

	err = tcgetattr(fd, &tio);
	if(err < 0){
		throw TermError::Raw_Mode_Fail;
	}

	tio.c_lflag &= ~(ECHO | ICANON | ISTRIP);
	tio.c_iflag &= ~(IXON | IXOFF);

	err = tcsetattr(fd, TCSAFLUSH, &tio);
	if(err < 0){
		throw TermError::Raw_Mode_Fail;
	}
}

void flush(){
	fflush(stdout);
}

void disable_raw_mode(){
	auto fd = stdout_fd;
	i32 err = 0;
	struct termios tio{};

	err = tcgetattr(fd, &tio);
	if(err < 0){
		throw TermError::Raw_Mode_Fail;
	}

	tio.c_lflag |= ECHO | ICANON;

	err = tcsetattr(fd, TCSAFLUSH, &tio);
	if(err < 0){
		throw TermError::Raw_Mode_Fail;
	}
}

void move_cursor(i32 amount, Direction d){
	printf("\e[%d%c", amount, char(d));
}

void set_cursor(i32 x, i32 y){
	printf("\e[%d;%dH", y, x);
}

void clear(){
	puts(clear_screen);
}

x::Pair<i32> get_dimensions(){
	struct winsize win{};
	i32 err = ioctl(stdout_fd, TIOCGWINSZ, &win);
	if(err < 0){
		throw TermError::Get_Dimensions_Fail;
	}
	auto width  = (i32)win.ws_col;
	auto height = (i32)win.ws_row;
	return {width, height};
}

}
