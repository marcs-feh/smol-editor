//+private linux
package smol_editor

import "core:fmt"
import "core:log"
import "core:time"
import "core:sys/linux"
import "core:unicode/utf8"
import "terminal"

@private
INPUT_INTERVAL :: 4 * time.Millisecond

_query_input :: proc(queue: ^Input_Queue){
	@thread_local input_buf : [4096]byte
	@thread_local rune_buf : [1024]rune
	read, _ := linux.read(linux.STDIN_FILENO, input_buf[:])
	
	buf := input_buf[:read]
	rune_count := 0
	for len(buf) > 0 {
		r, n := utf8.decode_rune(buf)
		if n == 0 { break }

		switch r { // Transform ascii escape sequences into multi rune entries
		case 0x03:
			input_queue_push_from(queue, []rune{CTRL, 'c'})
		case 0x13:
			input_queue_push_from(queue, []rune{CTRL, 's'})
		}

		buf = buf[n:]
		rune_buf[rune_count] = r
		rune_count += 1
	}

	input_queue_push_from(queue, rune_buf[:rune_count])
	time.sleep(INPUT_INTERVAL)
}

