//+private linux
package smol_editor

import "core:fmt"
import "core:log"
import "core:time"
import "core:sys/linux"
import "core:unicode/utf8"
import "terminal"
import sa "core:container/small_array"

@private
INPUT_INTERVAL :: 4 * time.Millisecond

_query_input :: proc(queue: ^Input_Queue){
	@thread_local input_buf : [4096]byte
	@thread_local rune_buf : sa.Small_Array(1024, rune)

	read, _ := linux.read(linux.STDIN_FILENO, input_buf[:])
	
	buf := input_buf[:read]
	for len(buf) > 0 {
		r, n := utf8.decode_rune(buf)
		if n == 0 { break }
		buf = buf[n:]

		// Transform ascii escape sequences into multi rune entries
		if r <= 0x1a {
			sa.append(&rune_buf, CTRL, 'a' + r - 1)
		}
		else {
			sa.append(&rune_buf, r)
		}
	}

	input_queue_push_from(queue, sa.slice(&rune_buf))
	rune_buf.len = 0
	time.sleep(INPUT_INTERVAL)
}

