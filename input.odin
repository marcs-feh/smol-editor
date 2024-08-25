package smol_editor

import "core:mem"
import "core:sync"
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


import "core:thread"
import "core:time"
import "core:fmt"

main :: proc(){
	@static stdout_mutex : sync.Mutex
	queue, _ := input_queue_create(256)

	@static pushes := 0
	@static pops := 0

	@static failed_pushes := 0
	@static failed_pops := 0

	t0 := thread.create_and_start_with_data(&queue, proc(p: rawptr){
		queue := transmute(^Input_Queue)p
		for _ in 0..=200{
			letters := [26]rune{}
			letters += 'a'
			for &l, i in letters {
				l += rune(i)
			}
			begin := time.now()
			n := input_queue_push_from(queue, letters[:])
			elapsed := time.since(begin)

			pushes += n
			failed_pushes += len(letters) - n

			if n > 0 {
				sync.mutex_guard(&stdout_mutex)
				fmt.printfln("push,%v,%v", i64(elapsed), n)
			}
		}
	})
	// defer thread.destroy(t0)

	t1 := thread.create_and_start_with_data(&queue, proc(p: rawptr){
		queue := transmute(^Input_Queue)p
		for {
			begin := time.now()
			buf : [8]rune
			n := input_queue_pop_into(queue, buf[:])
			elapsed := time.since(begin)
			pops += n
			failed_pops += len(buf) - n

			if n > 0 {
				sync.mutex_guard(&stdout_mutex)
				fmt.printfln("pop,%v,%v", i64(elapsed), n)
			}
		}
	})
	// defer thread.destroy(t1)

	time.sleep(1000 * time.Millisecond)
	fmt.println("OK:    Pushes:", pushes, "Pops:", pops)
	fmt.println("FAIL:  Pushes:", failed_pushes, "Pops:", failed_pops)
	fmt.println("TOTAL: Pushes:", pushes + failed_pushes, "Pops:", pops + failed_pops)
	fmt.printfln("Failure rate: %.2f", 1 - f64(pushes)/f64(pushes + failed_pushes))
}

// TODO: Benchmark the powerof2 optimization

