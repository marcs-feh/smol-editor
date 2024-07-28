#include <cstdio>
#include <cstdlib>

#include "assert.hpp"

namespace x {

struct AssertionError : public Error { AssertionError(cstring msg):Error(msg){} };

#ifdef NO_BOUNDS_CHECKING
constexpr
void bounds_check(bool pred){ (void)pred; }
#else
void bounds_check(bool pred){
	if(!pred){
		throw AssertionError("Bounds check failed");
	}
}
#endif

void assert_expr(bool pred, cstring msg){
	if(!pred){
		throw AssertionError(msg);
	}
}

[[noreturn]]
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

