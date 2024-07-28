#pragma once

#include "types.hpp"
#include "assert.hpp"

namespace x {

template<typename T, isize N>
struct Array {
	T data[N];

	constexpr
	T& operator[](isize idx){
		bounds_check(idx >= 0 && idx < N);
		return data[idx];
	}

	constexpr
	T const& operator[](isize idx) const {
		bounds_check(idx >= 0 && idx < N);
		return data[idx];
	}
};

/* Auto generated code for element-wise operations */
template<typename T, isize N> constexpr Array<T, N> operator+(Array<T,N> const& a, Array<T,N> const& b){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] + b[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator-(Array<T,N> const& a, Array<T,N> const& b){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] - b[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator*(Array<T,N> const& a, Array<T,N> const& b){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] * b[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator/(Array<T,N> const& a, Array<T,N> const& b){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] / b[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator%(Array<T,N> const& a, Array<T,N> const& b){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] % b[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator&(Array<T,N> const& a, Array<T,N> const& b){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] & b[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator|(Array<T,N> const& a, Array<T,N> const& b){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] | b[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator^(Array<T,N> const& a, Array<T,N> const& b){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] ^ b[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator+(Array<T,N> const& a){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = + a[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator-(Array<T,N> const& a){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = - a[i];}return res;}
template<typename T, isize N> constexpr Array<T, N> operator~(Array<T,N> const& a){Array<T, N> res;for(isize i = 0; i < N; i += 1){res[i] = ~ a[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator&&(Array<T,N> const& a, Array<T,N> const& b){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] && b[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator||(Array<T,N> const& a, Array<T,N> const& b){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] || b[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator==(Array<T,N> const& a, Array<T,N> const& b){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] == b[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator!=(Array<T,N> const& a, Array<T,N> const& b){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] != b[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator>=(Array<T,N> const& a, Array<T,N> const& b){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] >= b[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator<=(Array<T,N> const& a, Array<T,N> const& b){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] <= b[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator>(Array<T,N> const& a, Array<T,N> const& b){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] > b[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator<(Array<T,N> const& a, Array<T,N> const& b){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = a[i] < b[i];}return res;}
template<typename T, isize N> constexpr Array<bool, N> operator!(Array<T,N> const& a){Array<bool, N> res;for(isize i = 0; i < N; i += 1){res[i] = ! a[i];}return res;}


}

