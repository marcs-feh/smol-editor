#include "mem.hpp"

#if defined(__clang__) || defined(__GNUC__) 
#define USE_BUILTIN_MEM_PROCS 1
#endif
#undef USE_BUILTIN_MEM_PROCS

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
	__builtin_memmove(dest, src, n);
#else
	auto sp = reinterpret_cast<byte const*>(src);
	auto dp = reinterpret_cast<byte*>(dest);

	if(dp == sp){ return; }

	// No risk of overlap
	if(uintptr(sp) - uintptr(dp - n) <= -2 * n){
		return mem_copy_no_overlap(dest, src, n);
	}

	if(dp < sp){
		// for(; n; n--){ *dp++ = *sp++; }
		for(isize i = 0; i < n; i += 1){
			dp[i] = sp[i];
		}
	}
	else {
		// while(n) n--, dp[n] = sp[n];
		for(isize i = 0; i < n; i += 1){
			auto pos = n - (i + 1);
			dp[pos] = sp[pos];
		}
	}

#endif
}

void mem_copy_no_overlap(void* dest, void const * src, isize n){
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
