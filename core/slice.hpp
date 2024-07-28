#pragma once

#include "types.hpp"
#include "assert.hpp"

namespace x {

template<typename T>
struct Slice {
	T* data = nullptr;
	isize length = 0;

	constexpr
	T& operator[](isize idx){
		bounds_check(idx > 0 && idx < length);
		return data[idx];
	}

	constexpr
	T const& operator[](isize idx) const {
		bounds_check(idx > 0 && idx < length);
		return data[idx];
	}

	constexpr
	Slice<T> sub(isize start, isize end) {
		bounds_check(start >= 0 && end >= 0 && end <= length && start <= end);
		return Slice<T>::from_pointer(data + start, end - start);
	}

	constexpr
	bool empty() const {
		return length == 0 || data == nullptr;
	}

	constexpr
	static Slice<T> from_pointer(T* data, isize length){
		Slice<T> s;
		s.data = data;
		s.length = length;
		return s;
	}
};

template<typename T>
bool slice_equal(Slice<T> a, Slice<T> b){
	if(a.length != b.length){ return false; }

	for(isize i = 0; i < a.length; i += 1){
		if(a[i] != b[i]){ return false; }
	}

	return true;
}


template<typename T>
Slice<T> make_slice(isize n){
	T* data = new T[n];
	return Slice<T>::from_pointer(data, n);
}

template<typename T>
void delete_slice(Slice<T>& s){
	delete [] s.data;
	s.data = nullptr;
	s.length = 0;
}
}

