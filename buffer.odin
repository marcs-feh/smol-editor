package editor

import "core:fmt"
import "core:strings"
import gb "gap_buffer"

Buffer :: struct {
	using gap_buf: gb.Gap_Buffer,
	lines: [dynamic]int,
	name: string,
}

@private
DEFAULT_GAP :: 1024

// Creates a buffer, note that the name is copied to the buffer, for safety reasons
buffer_make :: proc(name: string, allocator := context.allocator) -> (buf: Buffer, err: gb.Buffer_Error){
	defer if err != nil {
		buffer_destroy(&buf)
	}
	buf.name = strings.clone(name) or_return
	buf.gap_buf = gb.buffer_make(DEFAULT_GAP, allocator) or_return
	buf.lines = make([dynamic]int) or_return
	return
}

buffer_destroy :: proc(buf: ^Buffer){
	delete(buf.name)
	gb.buffer_destroy(&buf.gap_buf)
	delete(buf.lines)
}
