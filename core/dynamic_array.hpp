#pragma once

#include "types.hpp"
#include <new>

namespace x {

template<typename T>
struct DynArray {
	T* data;
	isize capacity;
	isize length;

	// void append(T const& v){}
};

}
