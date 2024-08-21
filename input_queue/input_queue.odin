package input_queue

import "base:builtin"

Input_Queue :: struct {
	data: []rune,
	base: int,
	length: int,
}

@private
is_power_of_two :: proc "contextless" (n: int) -> bool {
	return (n & (n - 1)) == 0
}

queue_make :: proc(buf: []rune) -> Input_Queue {
	assert(is_power_of_two(builtin.len(buf)), "Length must be power of 2")

	queue := Input_Queue {
		data = buf,
		base = 0,
		length = 0,
	}

	return queue
}

push :: proc(q: ^Input_Queue, r: rune) -> bool {
	if q.length >= builtin.len(q.data) { return false }

	// Fast mod
	pos := (q.base + q.length) & (builtin.len(q.data) - 1)
	q.data[pos] = r
	q.length += 1
	return true
}

pop :: proc(q: ^Input_Queue) -> rune {
	if q.length == 0 { return 0; }

	front := q.data[q.base]
	// Fast mod
	q.base = (q.base + 1) & (builtin.len(q.data) - 1) 
	q.length -= 1
	return front
}

len :: queue_len

queue_len :: proc(q: Input_Queue) -> int {
	return q.length
}
