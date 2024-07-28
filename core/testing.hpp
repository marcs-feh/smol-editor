#pragma once

#include "types.hpp"
#include <thread>
#include <cstdio>

namespace x {
struct Test;

using TestFunc = void (*) (Test& t);

struct Test {
	cstring title = "";
	i32 failed = 0;
	i32 total = 0;

	template<typename ...Rest>
	void print(cstring fmt, Rest&& ... rest){
		std::printf("  > ", title);
		std::printf(fmt, rest...);
		std::printf("\n");
	}

	// Add a success to the test
	void success(isize n = 1){
		total += n;
	}

	// Add a failure to the test
	void fail(isize n = 1){
		total += n;
		failed += n;
	}

	bool expect(bool pred, cstring msg = nullptr){
		if(!pred){
			failed += 1;
			if(msg != nullptr) {
				std::printf("Fail: %s\n", msg);
			}
		}
		total += 1;
		return pred;
	}

	void report(){
		if(total == 0){
			std::printf("[%s] No tests to run\n", title);
			return;
		}
		auto ok = failed == 0;
		std::printf("[%s] %s\e[0m ok in %d/%d\n",
			  title, ok ? "\e[0;32mPASS" : "\e[0;31mFAIL", total - failed, total);
	}

	static bool run(cstring title, TestFunc fn){
		auto T = Test(title);
		fn(T);
		T.report();
		return T.failed == 0;
	}

	Test(cstring title) : title{title}{}
};

}

