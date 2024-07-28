package term

import "core:fmt"
import str "core:strings"

CSI :: "\e["

Color :: enum {
	Black   = 0,
	Red     = 1,
	Green   = 2,
	Yellow  = 3,
	Blue    = 4,
	Magenta = 5,
	Cyan    = 6,
	White   = 7,
}

// The x,y coordinates are 0-indexed.
set_cursor :: proc(buf: ^str.Builder, x, y: int){
	fmt.sbprintf(buf, CSI + "%d;%dH", y + 1, x + 1)
}

printf :: proc(buf: ^str.Builder, format: string, args: ..any){
	fmt.sbprintf(buf, format, ..args)
}

clear_screen :: proc(buf: ^str.Builder) {
	fmt.sbprintf(buf, CSI + "2J" + CSI + "3J")
}
