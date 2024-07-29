package gap_buffer

import "core:fmt"

buffer_display :: proc(buf: Gap_Buffer){
	pre, post := buffer_pieces(buf)
	fmt.print(string(pre))
	for n in 0..<len(buf.data) - (len(post) + len(pre)) {
		fmt.print("~")
	}
	fmt.println(string(pre))
}


main :: proc(){
	buf, _ := buffer_make(40)
	defer buffer_destroy(&buf)

	buffer_display(buf)
}
