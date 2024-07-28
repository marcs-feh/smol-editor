//+private linux
package term

import "core:sys/linux"
foreign import tty "tty_linux.o"

@(private="file")
foreign tty {
	tty_enable_raw_mode :: proc(fd: i32) -> i32 ---
	tty_disable_raw_mode :: proc(fd: i32) -> i32 ---
	tty_get_dimensions :: proc(fd: i32, w, h: ^i32) -> i32 ---
}

_enable_raw_mode :: proc(t: TermHandle) -> bool {
	e := tty_enable_raw_mode(i32(t))
	return e >= 0
}

_disable_raw_mode :: proc(t: TermHandle) -> bool {
	e := tty_disable_raw_mode(i32(t))
	return e >= 0
}

_get_dimensions :: proc(t: TermHandle) -> (w: int, h: int, ok: bool) {
	w_in, h_in : i32
	e := tty_get_dimensions(i32(t), &w_in, &h_in)
	ok = e >= 0
	w, h = int(w_in), int(h_in)
	return
}

_get_stdout_handle :: proc() -> TermHandle {
	return 1
}

_write_data :: proc(t: TermHandle, data: []byte) -> bool {
	_, e := linux.write(linux.Fd(t), data);
	return i32(e) >= 0
}

