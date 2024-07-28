#pragma once

#include "types.hpp"
#include <new>

namespace x {

template<typename T>
T align_forward(T val, T align){
	assert_expr((val & (val - 1)) == 0 && val > 0, "Invalid alignment");
	T aligned = val;
	T mod = val & (align - 1); // Faster version of val % align, only for powers of 2

	if(mod != 0){
		aligned += align - mod;
	}

	return aligned;
}

void mem_set(void* p, byte val, isize n);

void mem_copy(void* dest, void const* src, isize n);

void mem_copy_no_overlap(void* dest, void const* src, isize n);

template<typename T, typename ...Args>
T* construct(void* loc, Args&& ...args){
	T* obj = new (loc) T(args...); // TODO: Forward
	return obj;
}

}
