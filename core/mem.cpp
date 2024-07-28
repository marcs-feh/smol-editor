#include "mem.hpp"

#if defined(__clang__) || defined(__GNUC__) 
#define USE_BUILTIN_MEM_PROCS 1
#endif

namespace x {

void mem_set(void* p, byte val, isize n){
#ifdef USE_BUILTIN_MEM_PROCS
	__builtin_memset(p, val, n);
#else
	byte* bp = reinterpret_cast<byte*>(p);
	for(isize i = 0; i < n; i += 1){
		bp[i] = val;
	}
#endif
}

void mem_copy(void* dest, void const * src, isize n){
#ifdef USE_BUILTIN_MEM_PROCS
	__builtin_memcpy(dest, src, n);
#else
	auto sp = reinterpret_cast<byte const*>(src);
	auto dp = reinterpret_cast<byte*>(dest);
	for(isize i = 0; i < n; i += 1){
		dp[i] = sp[i];
	}
#endif
}

}
