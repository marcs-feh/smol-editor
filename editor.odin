package smol_editor

Id :: distinct i32

Editor_State :: struct {
	buffers: [dynamic]Buffer,  // Buffers are the internal representation of editable text
	views: [dynamic]Text_View, // A view is some metadata on how a buffer is rendered

	input_queue: ^Input_Queue, // Global input queue
	active_buffer: Id,
}
