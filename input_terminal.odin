//+private linux
package smol_editor

import "core:fmt"
import "core:sys/linux"
import "core:unicode/utf8"
import "terminal"

_query_input :: proc(queue: ^Input_Queue){
	@thread_local input_buf : [4096]byte
	@thread_local rune_buf : [1024]rune
	read, err := linux.read(linux.STDIN_FILENO, input_buf[:])
	if err != nil {
		panic("NOOO")
	}
	
	buf := input_buf[:read]
	rune_count := 0
	for {
		r, n := utf8.decode_rune(buf)
		if n == 0 { break }

		buf = buf[n:]
		rune_buf[rune_count] = r
		rune_count += 1
	}

	input_queue_push_from(queue, rune_buf[:rune_count])
}
