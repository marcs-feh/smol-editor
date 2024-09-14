package smol_editor

import "core:log"
import "core:fmt"
import "core:time"
import "core:sync"
import "core:os"
import "core:unicode/utf8"
import "core:sys/linux"
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

app_state : Editor_State

@(private="file")
global_input_queue : Input_Queue

main :: proc(){
	if ok := term.enable_raw_mode(term_handle); !ok {
		log.fatalf("Unable to set raw mode to terminal.")
	}
	defer term.disable_raw_mode(term_handle)

	logfile, file_err := os.open("log.txt", os.O_CREATE | os.O_RDWR, 0o644)
	if file_err != nil {
		fmt.eprintf("Failed to create log file.")
	}

	defer commit_logfile: {
		os.close(logfile)
		_ = os.remove("log.txt.old")
		e := os.rename("log.txt", "log.old.txt")
		if e != nil {
			log.fatal("Failed to create log file")
		}
	}

	context.logger = log.create_file_logger(logfile, lowest = .Info)
	defer log.destroy_file_logger(context.logger)

	err := init_editor(&app_state, &global_input_queue)
	assert(err == nil)

	global_input_queue, err = input_queue_create(128)
	assert(err == nil)

	start_editor_workers(&app_state)

	log.info("Initialized editor.")
	tmp_buf := make([dynamic]rune)

	tbuf := get_terminal_buffer()
	for {
		term.clear_screen(tbuf)
		w, h, _ := term.get_dimensions(term_handle)
		draw_statusbar("hello.odin", w, h)

		{
			ibuf : [256]rune
			n := input_queue_pop_into(app_state.input_queue, ibuf[:len(ibuf) - 1])
			for r, i in ibuf[:n]{
				if r == CTRL && ibuf[i+1] == 'c' {
					return
				}
			}
			term.set_cursor(tbuf, 0, 2)
			if n > 0 {
				log.info(tmp_buf[:])
				append(&tmp_buf, ..ibuf[:n])
			}
		}

		term.set_cursor(tbuf, 0, 0)
		term.write_buffer(term_handle, tbuf)
		time.sleep(16 * time.Millisecond)
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

