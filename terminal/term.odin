package term

import "core:strings"

TermHandle :: distinct uintptr

enable_raw_mode :: proc(t: TermHandle) -> bool {
	return _enable_raw_mode(t)
}

disable_raw_mode :: proc(t: TermHandle) -> bool {
	return _disable_raw_mode(t)
}

get_dimensions :: proc(t: TermHandle) -> (w: int, h: int, ok: bool) {
	return _get_dimensions(t)
}

get_stdout_handle :: proc() -> TermHandle {
	return _get_stdout_handle()
}

// Write buffer to terminal and reset it
write_buffer :: proc(t: TermHandle, buf: ^strings.Builder){
	write_data(t, buf.buf[:])
	strings.builder_reset(buf)
}

write_data :: proc(t: TermHandle, data: []byte) -> bool {
	return _write_data(t, data)
}
