#pragma once

#include "core.hpp"

#include <cstdlib>
#include <cstdio>

namespace x {

#ifdef NO_BOUNDS_CHECKING
constexpr
void bounds_check(bool pred){
	(void)pred;
}
#else

void bounds_check(bool pred){
	if(!pred){
		throw AssertionFailure("Bounds check failed");
	}
}
#endif

void assert_expr(bool pred, cstring msg){
	if(!pred){
		throw AssertionFailure(msg);
	}
}

void panic(cstring msg){
	fprintf(stderr, "Panic: %s", msg);
	do { abort(); } while(true);
}

[[noreturn]]
void unimplemented(){
	fprintf(stderr, "Unimplemented code.");
	do { abort(); } while(true);
}

}

