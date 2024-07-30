package gap_buffer

import "core:fmt"
import "core:mem"

Buffer_Error :: union #shared_nil {
	mem.Allocator_Error,
}

Gap_Buffer :: struct {
	data: []byte,
	gap_start: int,
	gap_end: int,

	allocator: mem.Allocator,
}

buffer_make :: proc(gap: int, allocator := context.allocator) -> (buf: Gap_Buffer, err: Buffer_Error){
	assert(gap >= MIN_GAP, "Gap is too small")
	data := make([]byte, gap, allocator) or_return
	buf.data = data
	buf.gap_end = len(data)
	buf.allocator = allocator
	return
}

buffer_destroy :: proc(buf: ^Gap_Buffer){
	delete(buf.data, buf.allocator)
	buf.gap_end, buf.gap_end = 0, 0
}

buffer_pieces :: proc(buf: Gap_Buffer) -> (pre, post: []byte){
	pre, post = buf.data[:buf.gap_start], buf.data[buf.gap_end:]
	return
}

gap_size :: proc(buf: Gap_Buffer) -> int {
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

gap_grow :: proc(buf: ^Gap_Buffer, size: int) -> Buffer_Error {
	unimplemented()
}

insert_text :: proc(buf: ^Gap_Buffer, pos: int) -> Buffer_Error {
	unimplemented()
}

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

