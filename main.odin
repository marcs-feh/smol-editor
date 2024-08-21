package smol_editor

import rl "vendor:raylib"

load_font :: proc(data: []byte, size: int) -> rl.Font {
	return rl.LoadFontFromMemory(".TTF", raw_data(data), auto_cast len(data), auto_cast size, nil, -1)
}

unload_font :: proc(f: rl.Font){
	rl.UnloadFont(f)
}

@private FONT :: #load("assets/inconsolata.ttf", []byte)

main :: proc(){
	rl.InitWindow(600, 400, "editor")
	rl.SetTargetFPS(60)
	defer rl.CloseWindow()

	font := load_font(FONT, 17)
	defer unload_font(font)

	lines := []cstring {
		"int main(){\n",
		"    printf(\"Hello\");\n",
		"}\n",
	}

	for !rl.WindowShouldClose(){
		render: {
			rl.BeginDrawing()
			defer rl.EndDrawing()

			rl.ClearBackground(rl.BLACK)

			for line, i in lines {
				off := f32(int(font.baseSize) * i)
				rl.DrawTextEx(font, line, [2]f32{10, 10} + [2]f32{0, off}, auto_cast font.baseSize, 0, rl.WHITE)
			}
		}
	}

}
