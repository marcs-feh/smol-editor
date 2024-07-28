#include <cstdio>
#include <cstdlib>

#include "assert.hpp"

namespace x {

#ifdef NO_BOUNDS_CHECKING
constexpr
void bounds_check(bool pred){ (void)pred; }
#else
void bounds_check(bool pred){
	if(!pred){
		throw Error("Bounds check failed");
	}
}
#endif

void assert_expr(bool pred, cstring msg){
	if(!pred){
		throw Error(msg);
	}
}

void panic(cstring msg){
	std::fprintf(stderr, "Panic: %s", msg);
	do { std::abort(); } while(true);
}

[[noreturn]]
void unimplemented(){
	std::fprintf(stderr, "Unimplemented code.");
	do { std::abort(); } while(true);
}

}

