package gap_buffer

import "core:fmt"
import "core:mem"
import "core:unicode/utf8"

// TODO: OOB Checks?

Buffer_Error :: union #shared_nil {
	mem.Allocator_Error,
}

Gap_Buffer :: struct {
	data: []byte,
	gap_start: int,
	gap_end: int,

	line_starts: [dynamic]int,

	allocator: mem.Allocator,
}

// Create a gap buffer, the buffer will use the provided allocator for its own operations
buffer_make :: proc(gap: int, allocator := context.allocator) -> (buf: Gap_Buffer, err: Buffer_Error){
	assert(gap >= MIN_GAP, "Gap is too small")
	data := make([]byte, gap, allocator) or_return
	defer if err != nil { delete(data, allocator) }
	buf.line_starts, err = make([dynamic]int, allocator=allocator)
	buf.data = data
	buf.gap_end = len(data)
	buf.allocator = allocator
	return
}

// Destroy buffer using its own allocator
buffer_destroy :: proc(buf: ^Gap_Buffer){
	delete(buf.data, buf.allocator)
	delete(buf.line_starts)
	buf.gap_end, buf.gap_end = 0, 0
}

// Get the date before and after the gap
buffer_pieces :: proc(buf: Gap_Buffer) -> (pre, post: []byte){
	pre, post = buf.data[:buf.gap_start], buf.data[buf.gap_end:]
	return
}

// Get buffer's gap size
gap_size :: #force_inline proc "contextless" (buf: Gap_Buffer) -> int {
	return buf.gap_end - buf.gap_start
}

// Transform a logical byte offset into a internal buffer offset
to_raw_position :: proc(buf: Gap_Buffer, p: int) -> int {
	return p + (gap_size(buf) if p > buf.gap_start else 0)
}

// Transform a internal buffer offset into a logical byte offset
from_raw_position :: proc(buf: Gap_Buffer, r: int) -> int {
	assert(r < buf.gap_start || r >= buf.gap_end, "Cannot translate from middle of gap.")
	return r - (gap_size(buf) if r < buf.gap_start else 0)
}

// Resize gap, moves it to the end
gap_resize :: proc(buf: ^Gap_Buffer, size: int) -> (err: Buffer_Error) {
	// assert(size >= MIN_GAP, "Gap is too small")
	pre, post := buffer_pieces(buf^)
	new_data := make([]byte, len(pre) + len(post) + size, buf.allocator) or_return

	 #no_bounds_check {
		mem.copy_non_overlapping(&new_data[0], raw_data(pre), len(pre))
		mem.copy_non_overlapping(&new_data[len(pre)], raw_data(post), len(post))
	 }

	delete(buf.data, buf.allocator)

	buf.gap_start = len(pre) + len(post)
	buf.gap_end = len(new_data)
	buf.data = new_data

	return
}

insert_text :: proc {
	insert_text_bytes,
	insert_text_string,
	insert_rune,
}

insert_text_bytes :: proc(buf: ^Gap_Buffer, pos: int, text: []byte) -> Buffer_Error {
	if len(text) >= gap_size(buf^) {
		gap_resize(buf, len(text) + MIN_GAP) or_return
	}
	unimplemented()
}

insert_text_string :: proc(buf: ^Gap_Buffer, pos: int, text: string) -> Buffer_Error {
	return insert_text_bytes(buf, pos, transmute([]byte)text)
}

insert_rune :: proc(buf: ^Gap_Buffer, pos: int, r: rune) -> Buffer_Error {
	b, n := utf8.encode_rune(r)
	return insert_text_bytes(buf, pos, b[:n])
}

// Move the start of the gap to pos, note that pos is a raw offset in the buffer.
gap_move :: proc(buf: ^Gap_Buffer, pos: int){
	if pos == buf.gap_start { return }
	region_to_save, region_freed : []byte
	delta := pos - buf.gap_start

	if pos < buf.gap_start {
		region_to_save = buf.data[buf.gap_start + delta:buf.gap_start]
		region_freed   = buf.data[buf.gap_end + delta:buf.gap_end]
	} else {
		region_to_save = buf.data[buf.gap_end:buf.gap_end + delta]
		region_freed   = buf.data[buf.gap_start:buf.gap_start + delta]
	}

	mem.copy(raw_data(region_freed), raw_data(region_to_save), abs(delta))
	buf.gap_start = pos
	buf.gap_end += delta

	assert(len(region_freed) == abs(delta) && len(region_to_save) == abs(delta))
	assert(buf.gap_start < len(buf.data) && buf.gap_end <= len(buf.data))
}

MIN_GAP :: 8

