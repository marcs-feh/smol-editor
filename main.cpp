#include "terminal/terminal.hpp"
#include "core/assert.hpp"
#include <cstdio>
#include <unistd.h>
#include <thread>


int main(){
	term::enable_raw_mode();
	int n = 0;
	while(true){
		term::clear();
		putc(0, stdout);
		auto [w, h] = term::get_dimensions();
		term::set_cursor(0, 0);
		printf("[%dx%d] %d", w, h, n);

		term::set_cursor(n, n);

		n++;
		term::flush();
		usleep(50'000);
	}
	return 0;
}
