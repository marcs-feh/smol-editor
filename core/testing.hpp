#pragma once

#include "types.hpp"
#include <cstdio>

namespace x {
struct Test;

using TestFunc = void (*) (Test& t);

struct Test {
	cstring title = "";
	i32 failed = 0;
	i32 total = 0;

	bool expect(bool pred, cstring msg = ""){
		if(!pred){
			failed += 1;
			std::printf("Fail: %s\n", msg);
		}
		total += 1;
		return pred;
	}

	void report(){
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

