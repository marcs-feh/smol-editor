package smol_editor

import "core:fmt"
import "core:strings"
import gb "gap_buffer"

Cursor :: struct {
	pos: gb.Pos,
}

Line :: struct {
	length: i32,
}

Buffer :: struct {
	id: Id,
	using gap_buf: gb.Gap_Buffer,
	lines: [dynamic]Line,
	filename: string,
	cursor: Cursor,
}

@private
DEFAULT_GAP :: 1024

@private
has_newline :: proc {
	has_newline_bytes,
	has_newline_string,
}

@private
has_newline_bytes :: proc(bytes: []byte) -> bool {
	for b in bytes {
		if b == '\n' { return true }
	}
	return false
}

@private
has_newline_string :: proc(s: string) -> bool {
	return has_newline_bytes(transmute([]byte)s)
}

// Creates a buffer, note that the name is copied to the buffer, for safety reasons
buffer_make :: proc(name: string, allocator := context.allocator) -> (buf: Buffer, err: gb.Buffer_Error){
	defer if err != nil {
		buffer_destroy(&buf)
	}
	buf.filename = strings.clone(name) or_return
	buf.gap_buf = gb.buffer_make(DEFAULT_GAP, allocator) or_return
	return
}

// Destroy buffer
buffer_destroy :: proc(buf: ^Buffer){
	delete(buf.filename, buf.allocator)
	gb.buffer_destroy(&buf.gap_buf)
}

