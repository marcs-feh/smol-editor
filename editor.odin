package smol_editor

import "base:intrinsics"
import "core:mem"
import "core:thread"
import "core:time"
import "core:log"
import sl "spinlock"

Id :: distinct i32

Editor_State :: struct {
	buffers: [dynamic]Buffer,  // Buffers are the internal representation of editable text
	views: [dynamic]Text_View, // A view is some metadata on how a buffer is rendered

	input_queue: ^Input_Queue, // Global input queue
	active_buffer: Id,

	input_worker: ^thread.Thread,

	running: bool,
}

// Note that the queue must be heap allocated, as it will be observed by
// multiple threads.
init_editor :: proc(editor: ^Editor_State, queue: ^Input_Queue) -> (err: mem.Allocator_Error){
	editor.buffers = make([dynamic]Buffer) or_return
	editor.views = make([dynamic]Text_View) or_return
	editor.input_queue = queue

	lock := cast(^sl.Spinlock)new(struct {_:sl.Spinlock})

	return
}

start_editor_workers :: proc(editor: ^Editor_State){
	editor.input_worker = thread.create(input_worker_proc)
	if editor.input_worker == nil {
		log.fatal("Could not create input thread.")
		return
	}
	editor.running = true
	editor.input_worker.data = editor // Pass editor state down to thread
	thread.start(editor.input_worker)
	log.info("Spawned input worker")
}

input_worker_proc :: proc(thread_state: ^thread.Thread){
	editor_state := transmute(^Editor_State)thread_state.data
	queue := editor_state.input_queue

	for intrinsics.atomic_load_explicit(&editor_state.running, .Relaxed) {
		_query_input(queue)
	}
}
// TODO: spawn worker etc.



