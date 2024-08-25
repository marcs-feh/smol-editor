package smol_editor

import "core:fmt"
import "core:strings"
import gb "gap_buffer"

Cursor :: struct {
	pos: gb.Pos,
}

Buffer :: struct {
	using gap_buf: gb.Gap_Buffer,
	lines: [dynamic]int,
	name: string,
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

buffer_cursor_insert :: proc(buf: ^Buffer, data: []byte){
}

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

// Destroy buffer
buffer_destroy :: proc(buf: ^Buffer){
	delete(buf.name, buf.allocator)
	gb.buffer_destroy(&buf.gap_buf)
	delete(buf.lines)
}

// Update *ALL* lines
buffer_update_lines :: proc(buf: ^Buffer){
	clear(&buf.lines)
	for i in 0..<gb.text_size(buf.gap_buf){
		if gb.get_byte(buf^, i) == '\n' {
			append(&buf.lines, i)
		}
	}
}

// Increase line count from `start` onwards.
buffer_increase_line :: proc(buf: ^Buffer, start: int, delta: int){
	for i in start..<gb.text_size(buf.gap_buf){
		buf.lines[i] += delta
	}
}

