package spinlock

import "base:intrinsics"

Spinlock :: struct #no_copy {
	_locked: bool,
}

lock :: proc(l: ^Spinlock){
	// TTAS: test and test-and-set. Due to how CPUs handle atomicity in their
	// caches, this eliminates cache coherency traffic when the lock is
	// spinning.
	for {
		if !intrinsics.atomic_exchange_explicit(&l._locked, true, .Acquire) {
			break;
		}

		for intrinsics.atomic_load_explicit(&l._locked, .Relaxed) {
			/* Busy wait */
		}
	}
}

unlock :: proc(l: ^Spinlock){
	intrinsics.atomic_store_explicit(&l._locked, false, .Release)
}

