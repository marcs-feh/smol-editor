package gap_buffer

import "core:fmt"
import "core:mem"

buffer_display :: proc(buf: Gap_Buffer){
	pre, post := buffer_pieces(buf)
	fmt.print(string(pre))
	for n in 0..<len(buf.data) - (len(post) + len(pre)) {
		fmt.print("~")
	}
	fmt.println(string(post))
}


main :: proc(){
	buf, _ := buffer_make(8)
	defer buffer_destroy(&buf)

	msg := "Hello"
	buf.gap_start += len(msg)

	mem.copy(raw_data(buf.data), raw_data(string(msg)), len(msg))

	for n := 5; n >= 0; n -= 1 {
		gap_move(&buf, n)
		buffer_display(buf)
	}
	for n in 0..<6 {
		gap_move(&buf, n)
		buffer_display(buf)
	}

	gap_resize(&buf, 0)
	buffer_display(buf)

	gap_resize(&buf, 20)
	buffer_display(buf)
}
