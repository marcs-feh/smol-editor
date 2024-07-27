#pragma once

#include "types.hpp"

namespace x {
template<typename T>
struct Slice {
	T* data = nullptr;
	isize length = 0;

	T& operator[](isize idx){
		return data[idx];
	}

	static Slice<T> from_pointer(T* data, isize length){
		Slice<T> s;
		s.data = data;
		s.length = length;
	}
};
}

