#pragma once

// Core public interface
#include "slice.hpp"
#include "types.hpp"

namespace x {

struct AssertionFailure {
	cstring msg = "";

	cstring message(){
		return msg;
	}

	constexpr
	AssertionFailure(cstring msg) : msg{msg}{}
};

void assert_expr(bool pred, cstring msg = "");

void bounds_check(bool pred);

void panic(cstring msg);

[[noreturn]]
void unimplemented();

template<typename A, typename B = A>
struct Pair {
	A a;
	B b;
};

}
