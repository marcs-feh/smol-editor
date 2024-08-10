package gap_buffer

import "core:fmt"
import "core:mem"

buffer_display :: proc(buf: Gap_Buffer){
	pre, post := buffer_pieces(buf)
	fmt.printfln("Gap(%v) [% 3d, % 3d]:", gap_size(buf), buf.gap_start, buf.gap_end)
	fmt.printfln("Lines: %v", buf.line_starts[:])

	fmt.print(string(pre))
	for n in 0..<len(buf.data) - (len(post) + len(pre)) {
		fmt.print("~")
	}
	fmt.println(string(post))
	fmt.println("-----------------")
}


main :: proc(){
	buf, _ := buffer_make(MIN_GAP)
	defer buffer_destroy(&buf)


	// insert_text(&buf, 0, "Hello")
	// buffer_display(buf)
	//
	// insert_text(&buf, text_size(buf), " world")
	// buffer_display(buf)
	//
	// insert_text(&buf, 5, ",")
	// buffer_display(buf)
	//
	// insert_text(&buf, text_size(buf), "!")
	// buffer_display(buf)

	fmt.println(buffer_build_string(buf))
}
