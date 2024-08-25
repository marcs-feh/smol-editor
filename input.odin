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
	q.items = make([]rune, cap) or_return
	q.lock_ = transmute(^sl.Spinlock)new(struct {_: sl.Spinlock}) or_return
	return
}

input_queue_destroy :: proc(q: ^Input_Queue, allocator := context.allocator){
	delete(q.items, allocator)
	free(q.lock_)
	q.base, q.length, q.items = 0, 0, nil
}

_input_queue_push :: proc(q: ^Input_Queue, r: rune) -> bool {
	if q.length >= len(q.items) {
		return false
	}

	pos := (q.base + q.length) % len(q.items)
	q.items[pos] = r
	q.length += 1

	return true
}

_input_queue_pop :: proc(q: ^Input_Queue) -> (rune, bool) {
	if q.length <= 0 {
		return 0, false
	}

	r := q.items[q.base]
	q.base = (q.base + 1) % len(q.items)
	q.length -= 1
	return r, true
}

input_queue_push :: proc(q: ^Input_Queue, r: rune) -> bool {
	sl.guard(q.lock_)
	return _input_queue_push(q, r)
}

input_queue_pop :: proc(q: ^Input_Queue) -> (rune, bool) {
	sl.guard(q.lock_)
	return _input_queue_pop(q)
}

input_queue_push_from :: proc(q: ^Input_Queue, buf: []rune) -> (count: int){
	sl.guard(q.lock_)
	for r in buf {
		if ok := _input_queue_push(q, r); ok {
			count += 1
		}
		else {
			break
		}
	}
	return
}

input_queue_pop_into :: proc(q: ^Input_Queue, buf: []rune) -> (count: int) {
	sl.guard(q.lock_)
	for i in 0..<len(buf) {
		if r, ok := _input_queue_pop(q); ok {
			buf[i] = r
			count += 1
		}
		else {
			break
		}
	}
	return
}

// TODO: Benchmark the powerof2 optimization

