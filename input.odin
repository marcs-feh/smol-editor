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
	q.lock_ = transmute(^sl.Spinlock)new([size_of(sl.Spinlock)]byte) or_return
	return
}

input_queue_destroy :: proc(q: ^Input_Queue, allocator := context.allocator){
	delete(q.items, allocator)
	free(q.lock_)
	q.base, q.length, q.items = 0, 0, nil
}

input_queue_push :: proc(q: ^Input_Queue, r: rune) -> bool {
	sl.lock_guard(q.lock_)

	if q.length >= len(q.items) {
		return false
	}

	pos := (q.base + q.length) % len(q.items)
	q.items[pos] = r
	q.length += 1

	return true
}

input_queue_pop :: proc(q: ^Input_Queue) -> (rune, bool) {
	sl.lock_guard(q.lock_)

	if q.length <= 0 {
		return 0, false
	}

	r := q.items[q.base]
	q.base = (q.base + 1) % len(q.items)
	return r, true
}

import "core:thread"
import "core:time"
import "core:fmt"
main :: proc(){
	queue, _ := input_queue_create(32)

	thread.create_and_start_with_data(&queue, proc(p: rawptr){
		queue := transmute(^Input_Queue)p
		for {
			for r in 'a'..='z' {
				ok := input_queue_push(queue, r)
				if ok {
					fmt.println("IN: ", r)
				}
			}
		}
	})
	thread.create_and_start_with_data(&queue, proc(p: rawptr){
		queue := transmute(^Input_Queue)p
		for {
			r, ok := input_queue_pop(queue)
			if ok {
				fmt.println("OUT: ", r)
			}
		}
	})

	time.sleep(2 * time.Second)
}

// TODO: Benchmark the powerof2 optimization

