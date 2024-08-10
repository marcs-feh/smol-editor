package gap_buffer

import "core:fmt"
import "core:mem"
import "core:slice"
import ts "core:testing"

@(private="file")
scratch_allocator :: proc() -> mem.Allocator {
	@(thread_local) data : [1024 * 1024 * 8]byte
	@(thread_local) arena : mem.Arena
	mem.arena_init(&arena, data[:])
	return mem.arena_allocator(&arena)
}

@(test)
basic_editing :: proc(t: ^ts.T){
	buf, err := buffer_make(64)
	defer buffer_destroy(&buf)
	expect_all(t,
		err == nil,
		buf.gap_start == 0,
		int(buf.gap_end) == len(buf.data))
}

@(private="file")
expect :: #force_inline proc(t: ^ts.T, ok: bool){ ts.expect(t, ok) }

@(private="file")
expect_all :: #force_inline proc(t: ^ts.T, preds: ..bool){
	ok := true
	for p in preds { ok = ok && p }
	ts.expect(t, ok)
}

@(private="file")
expect_any :: #force_inline proc(t: ^ts.T, preds: ..bool){
	ok := false
	for p in preds { ok = ok || p }
	ts.expect(t, ok)
}

