#pragma once

#include "types.hpp"
#include "assert.hpp"
#include "slice.hpp"
#include <new>

namespace x {

template<typename T>
struct DynArray {
	T* data = nullptr;
	isize capacity = 0;
	isize length = 0;

	void clear(){
		unimplemented();
	}

	void resize(isize n){
		if(n < 0){ return; }

		if(n < length){
			unimplemented();
		}
		else {
			unimplemented();
		}
	}

	DynArray(){}

	void append(T const& v){
		if(length + 1 > capacity){
			resize(((capacity * 4) / 3) + 2);
		}
		new (&data[length]) T(v);
		length += 1;
	}

	static DynArray<T> make(isize capacity){
		assert_expr(capacity > 0, "Invalid capaciity");
		DynArray<T> arr;
		arr.data = reinterpret_cast<T*>(new byte[capacity * sizeof(T)]);
		arr.capacity = capacity;
		return arr;
	}

	Slice<T> slice(){
		return Slice<T>::from_pointer(data, length);
	}

	constexpr
	T& operator[](isize idx){
		bounds_check(idx >= 0 && idx < length);
		return data[idx];
	}

	constexpr
	T const& operator[](isize idx) const {
		bounds_check(idx >= 0 && idx < length);
		return data[idx];
	}

	~DynArray(){
		// delete
	}

};

}
