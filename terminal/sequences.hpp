#pragma once

#include "core/types.hpp"

namespace term {

// TODO: Replace with array
constexpr byte CSI[] = "\e[";
constexpr byte clear_screen[] = "\e[2J\e[3J";

enum struct Color : i8 {
	Black   = 0,
	Red     = 1,
	Green   = 2,
	Yellow  = 3,
	Blue    = 4,
	Magenta = 5,
	Cyan    = 6,
	White   = 7,
};

}
