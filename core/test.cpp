// Testing file, this is not part of the module's translation unit

#include "testing.hpp"

using namespace x;

int main(){
	Test::run("Slice", [](Test& T){
		T.expect(1 - 1 == 2);
		T.print("%d", 69);
	});
}
