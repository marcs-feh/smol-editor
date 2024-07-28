#include "terminal/terminal.hpp"
#include "core/testing.hpp"
#include "core/dynamic_array.hpp"
#include <cstdio>
#include <unistd.h>

int main(){
	using namespace x;

	Test::run("Dynamic Array", [](Test& T){
		auto arr = DynArray<i32>::make(100);
		T.expect(arr.length == 0 && arr.capacity == 100);
		arr.append(6);
		std::printf("[ "); for(isize i = 0; i < arr.length; i += 1){ std::printf("%d ", arr[i]); } std::printf("]\n");
		
		T.expect(arr.length == 1);
	});

	return 0;
}
