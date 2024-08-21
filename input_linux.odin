//+build linux
package editor

import "core:sys/linux"

_read_stdin :: proc(buf: []byte) -> int {
	n, _ := linux.read(linux.STDIN_FILENO, buf)
	return n
}
