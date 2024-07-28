#pragma once

namespace x {

template<typename A, typename B = A>
struct Pair {
	A a;
	B b;
};

template<typename T>
constexpr
T min(T a, T b){
	return (a < b) ? a : b;
}

template<typename T, typename ...Args>
constexpr
T min(T a, T b, Args&& ...args){
	if(a < b){
		return min(a, args...);
	}
	else {
		return min(b, args...);
	}
}

template<typename T>
constexpr
T max(T a, T b){
	return (a > b) ? a : b;
}

template<typename T, typename ...Args>
constexpr
T max(T a, T b, Args&& ...args){
	if(a > b){
		return max(a, args...);
	}
	else {
		return max(b, args...);
	}
}

}

