#pragma once

#include "types.hpp"

namespace x {
void bounds_check(bool pred);

void assert_expr(bool pred, cstring msg);

[[noreturn]]
void panic(cstring msg);

[[noreturn]]
void unimplemented();
}
