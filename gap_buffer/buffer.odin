package gap_buffer

import "core:fmt"
import "core:mem"
import "core:slice"
import "core:unicode/utf8"

MIN_GAP :: 8

// Virtual byte position into a string, does not take into consideration the
// gap, this is used for most of the Public functions
Pos :: int

// Raw byte offset from the start of the buffer, this is mainly for private
// usage or buffer memory manipulation
Offset :: distinct int

// TODO: OOB Checks?
Buffer_Error :: union #shared_nil {
	mem.Allocator_Error,
	enum byte {
		Out_Of_Bounds,
	},
}

Gap_Buffer :: struct {
	data: []byte,
	gap_start: Offset,
	gap_end: Offset,

	line_starts: [dynamic]Pos,

	allocator: mem.Allocator,
}

// Create a gap buffer, the buffer will use the provided allocator for its own operations
buffer_make :: proc(gap: int, allocator := context.allocator) -> (buf: Gap_Buffer, err: Buffer_Error){
	assert(gap >= MIN_GAP, "Gap is too small")
	data := make([]byte, gap, allocator) or_return
	defer if err != nil { delete(data, allocator) }
	buf.line_starts, err = make([dynamic]int, allocator=allocator)
	buf.data = data
	buf.gap_end = Offset(len(data))
	buf.allocator = allocator

	append(&buf.line_starts, 0)
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
	return int(buf.gap_end - buf.gap_start)
}

// Get buffer's text size (bytes)
text_size :: #force_inline proc "contextless" (buf: Gap_Buffer) -> int {
	return len(buf.data) - int(buf.gap_end - buf.gap_start)
}

// Transform a logical byte offset into a internal buffer offset
to_raw_position :: proc (buf: Gap_Buffer, p: Pos) -> Offset {
	after := Offset(p) > buf.gap_start
	return Offset(p + (gap_size(buf) if after else 0))
}

// Transform a internal buffer offset into a logical byte offset
from_raw_position :: proc(buf: Gap_Buffer, r: Offset) -> Pos {
	assert(r < buf.gap_start || r >= buf.gap_end, "Cannot translate from middle of gap.")
	before := r < buf.gap_start
	return Pos(r) - (gap_size(buf) if before else 0)
}

// Resize gap, moves it to the end.
gap_resize :: proc(buf: ^Gap_Buffer, size: int) -> (err: Buffer_Error) {
	assert(size >= MIN_GAP, "Gap is too small")
	pre, post := buffer_pieces(buf^)
	new_data := make([]byte, len(pre) + len(post) + size, buf.allocator) or_return

	 #no_bounds_check {
		mem.copy_non_overlapping(&new_data[0], raw_data(pre), len(pre))
		mem.copy_non_overlapping(&new_data[len(pre)], raw_data(post), len(post))
	 }

	delete(buf.data, buf.allocator)

	buf.gap_start = Offset(len(pre) + len(post))
	buf.gap_end = Offset(len(new_data))
	buf.data = new_data

	return
}

insert_text :: proc {
	insert_text_bytes,
	insert_text_string,
	insert_rune,
}

// Update line offsets
update_lines :: proc(buf: ^Gap_Buffer, start_pos: Pos){
	clear(&buf.line_starts)
	append(&buf.line_starts, 0)

	length := text_size(buf^)

	for i := 0; i < length; i += 1 {
		if get_byte(buf^, i) == '\n' {
			append(&buf.line_starts, i)
		}
	}
}

// Get a byte at position
get_byte :: proc (buf: Gap_Buffer, pos: Pos) -> byte {
	return buf.data[to_raw_position(buf, pos)]
}

// Insert a stream of raw bytes into position, this does *not* validate if the bytes are valid UTF-8
insert_text_bytes :: proc(buf: ^Gap_Buffer, pos: Pos, text: []byte) -> (err: Buffer_Error) {
	if len(text) >= gap_size(buf^) {
		gap_resize(buf, len(text) + MIN_GAP) or_return
	}
	pos := to_raw_position(buf^, pos)
	gap_move(buf, pos)
	mem.copy(&buf.data[buf.gap_start], raw_data(text), len(text))
	buf.gap_start += Offset(len(text))
	return
}

// Insert a string into position
insert_text_string :: proc(buf: ^Gap_Buffer, pos: Pos, text: string) -> Buffer_Error {
	return insert_text_bytes(buf, pos, transmute([]byte)text)
}

// Insert a UTF-8 encoded rune into position
insert_rune :: proc(buf: ^Gap_Buffer, pos: Pos, r: rune) -> Buffer_Error {
	b, n := utf8.encode_rune(r)
	return insert_text_bytes(buf, pos, b[:n])
}

// Move the start of the gap to position
gap_move :: proc(buf: ^Gap_Buffer, pos: Offset){
	if pos == buf.gap_start || pos < 0 { return }
	region_to_save, region_freed : []byte
	delta := pos - buf.gap_start

	if pos < buf.gap_start {
		region_to_save = buf.data[buf.gap_start + delta:buf.gap_start]
		region_freed   = buf.data[buf.gap_end + delta:buf.gap_end]
	} else {
		// If the delta causes the buffer's tail to overshoot, pull it back and proceed as normal
		if buf.gap_end + delta > Offset(len(buf.data)) {
			delta = Offset(len(buf.data)) - buf.gap_end
		}
		region_to_save = buf.data[buf.gap_end:buf.gap_end + delta]
		region_freed   = buf.data[buf.gap_start:buf.gap_start + delta]
	}

	mem.copy(raw_data(region_freed), raw_data(region_to_save), auto_cast abs(delta))
	buf.gap_start += delta
	buf.gap_end += delta

	assert(len(region_freed) == abs(int(delta)) && len(region_to_save) == abs(int(delta)))
	assert(int(buf.gap_start) < len(buf.data) && int(buf.gap_end) <= len(buf.data))
}

// Creates a new string from buffer's contents. You can use append_null = true
// to be able to safely cast the string's raw_data to a cstring.
buffer_build_string :: proc(
	buf: Gap_Buffer,
	allocator := context.allocator,
	append_null := false) -> (text: string, err: Buffer_Error)
{
	size := text_size(buf) + int(append_null)
	str_data := make([]byte, size, allocator) or_return
	pre, post := buffer_pieces(buf)

	#no_bounds_check {
		mem.copy_non_overlapping(&str_data[0], raw_data(pre), len(pre))
		mem.copy_non_overlapping(&str_data[len(pre)], raw_data(post), len(post))
	}

	text = string(str_data)
	return
}


#assert(size_of(Buffer_Error) <= size_of(int))
#assert(size_of(Pos) == size_of(Offset))

