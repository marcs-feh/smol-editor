#pragma once

#include "types.hpp"

struct Error {
	cstring msg = "";

	cstring message(){
		return msg;
	}

	constexpr
	Error(cstring msg) : msg{msg}{}
};

void assert_expr(bool pred, cstring msg = "");

void bounds_check(bool pred);

void panic(cstring msg);

[[noreturn]] void unimplemented();

