package smol_editor

import "core:mem"
import sl "spinlock"

Input_Queue :: struct {
	items: []rune,
	base: int,
	length: int,

	lock_: ^sl.Spinlock,
}

@(private="file")
is_pow_of_2 :: #force_inline proc(n: int) -> bool {
	return (n & (n - 1)) == 0
}

input_queue_create :: proc(cap: int, allocator := context.allocator) -> (q: Input_Queue, err: mem.Allocator_Error){
	q.items := make([]rune, cap) or_return
	q.lock_ := new(sl.Spinlock) or_return
	return
}

input_queue_destroy :: proc(q: ^Input_Queue, allocator := context.allocator){
	delete(q.items, allocator)
	q.base, q.length, q.items = 0, 0, nil
}

input_queue_push :: proc(q: ^Input_Queue, r: rune) -> bool {
	sl.lock(q.lock_)
	defer sl.unlock(q.lock_)

	if q.length >= len(q.items) {
		return false
	}

	pos := (q.base + q.length) % len(q.items)
	q.items[pos] = r
	q.length += 1

	return true
}

input_queue_pop :: proc(q: ^Input_Queue) -> (rune, bool) {}

// TODO: Benchmark the powerof2 optimization

