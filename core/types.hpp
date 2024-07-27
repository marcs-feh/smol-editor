#pragma once

#include <cstddef>
#include <cstdint>

using i8  = int8_t;
using i16 = int16_t;
using i32 = int32_t;
using i64 = int64_t;

using u8  = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;

using f32 = float;
using f64 = double;
using complex64 = _Complex float;
using complex128 = _Complex double;

using cstring = char const *;
using byte = char;
using rune = i32;

using isize = ptrdiff_t;
using usize = size_t;

using uintptr = uintptr_t;

static_assert(sizeof(isize) == sizeof(usize), "Mismatched size types");
static_assert(sizeof(f32) == 4 && sizeof(f64) == 8, "Non standard float types");
static_assert(sizeof(complex64) == 8 && sizeof(complex128) == 16, "Non standard complex types");

