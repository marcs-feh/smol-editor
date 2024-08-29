package smol_editor

consume_keys :: proc(queue: ^Input_Queue, batch: []rune){
	n := input_queue_pop_into(queue, batch)
	keys := batch[:n]

	unimplemented("check for keybinds")
}

get_keyboard_input :: proc(queue: ^Input_Queue){
	unimplemented()
}
