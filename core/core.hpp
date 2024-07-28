#pragma once

/* Core public interface */
#include "types.hpp"
#include "assert.hpp"
#include "slice.hpp"

namespace x {
template<typename A, typename B = A>
struct Pair {
	A a;
	B b;
};
}

