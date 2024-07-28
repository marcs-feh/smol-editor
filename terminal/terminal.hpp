#pragma once

#include "core/core.hpp"

namespace term {

enum class TermError {
	Raw_Mode_Fail = 1,
	Get_Dimensions_Fail,
};

enum class Direction : u8 {
	Up = 'A', Down = 'B', Right = 'C', Left = 'D',
};

void enable_raw_mode();

void disable_raw_mode();

void clear();

void flush();

void set_cursor(i32 line, i32 col);

void move_cursor(i32 amount, Direction d);

x::Pair<i32> get_dimensions();

}

