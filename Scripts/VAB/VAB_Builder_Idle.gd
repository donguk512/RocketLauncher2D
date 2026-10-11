extends BuilderState


func enter():
	pass

func on_mouse_button_down():
	var mouse_world_pos = builder.get_global_mouse_position()
	var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
	var clicked_part = PartPicker.get_part_at_pos(
		builder.get_world_2d().direct_space_state,
		mouse_world_pos
	)
	
	print(clicked_part)
	
	if clicked_part:
		if shift_pressed:
			selector.toggle(clicked_part)
			
		elif clicked_part not in selector.selected_parts:
			selector.clear()
			selector.select(clicked_part)
		
		builder.change_state("Drag")
	else:
		builder.change_state("Box")
		

func _rotate_selection(quarters: int) -> void:
	super(quarters)
	
	selector.finish_drag()
