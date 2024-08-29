package smol_editor

import "core:fmt"
import "core:time"
import "core:sync"
import "core:unicode/utf8"
import str "core:strings"
import term "terminal"

@private
term_handle := term.get_stdout_handle()

@private
get_terminal_buffer :: proc() -> ^str.Builder {
	@static term_buffer : str.Builder
	@static initialized := false

	if !initialized { str.builder_init(&term_buffer)
		initialized = true
	}

	return &term_buffer
}

main :: proc(){
	if ok := term.enable_raw_mode(term_handle); !ok {
		fmt.panicf("Unable to set raw mode to terminal.")
	}
	defer term.disable_raw_mode(term_handle)

	tbuf := get_terminal_buffer()
	in_queue, _ := input_queue_create(8)

	for {
		term.clear_screen(tbuf)
		w, h, _ := term.get_dimensions(term_handle)
		draw_statusbar("hello.odin", w, h)
		term.set_cursor(tbuf, 0, 0)
		term.write_buffer(term_handle, tbuf)
		time.sleep(100 * time.Millisecond)
	}
}

draw_statusbar :: proc(buffername: string, w, h: int){
	left_buf : [1024]byte
	right_buf : [1024]byte
	tbuf := get_terminal_buffer()
	term.set_cursor(tbuf, 0, h - 1)

	left := fmt.bprintf(left_buf[:], " %q", buffername)
	right := fmt.bprintf(right_buf[:], "(123:12) | utf-8[unix]")
	padding := w - (len(right) + len(left))

	if padding < 0 {
		unimplemented("truncate")
	}

	term.set_background(tbuf, .Black)
	term.set_foreground(tbuf, .Yellow)
	defer term.reset_color(tbuf)

	str.write_string(tbuf, left)
	for i in 0..<padding {
		str.write_byte(tbuf, byte(' '))
	}
	str.write_string(tbuf, right)
}

