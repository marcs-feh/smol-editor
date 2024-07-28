package term

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

write_data :: proc(t: TermHandle, data: []byte) -> bool {
	return _write_data(t, data)
}
