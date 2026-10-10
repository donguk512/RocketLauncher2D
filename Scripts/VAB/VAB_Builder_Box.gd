extends BuilderState

var mouse_start_pos: Vector2

func enter():
	selector.clear()
	mouse_start_pos = builder.get_global_mouse_position()

func on_mouse_button_up():
	selector.select_in_box()
	builder.change_state("Idle")

func on_mouse_move(event):
	selector.update_box(mouse_start_pos, builder.get_global_mouse_position())
