extends BuilderState

@onready var catalog: Panel = $"../../../UI/CatalogPanel"

var mouse_start_pos: Vector2

func enter():
	selector.start_drag()
	mouse_start_pos = builder.get_global_mouse_position()

func update(mouse_pos: Vector2) -> void:
	var mouse_delta = mouse_pos - mouse_start_pos
	selector.drag(mouse_delta)
	selector.snap()
	
func input(event: InputEvent):
	if event is InputEventMouseMotion:
		update(builder.get_global_mouse_position())
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.is_pressed():
				# Delete when dragged into catalog
				if catalog.is_hovered:
					selector.remove()
				selector.finish_drag()
				
				builder.change_state("Idle")


func _rotate_selection(quarters: int) -> void:
	super(quarters)
	
	var mouse_delta = builder.get_global_mouse_position() - mouse_start_pos
	
	for part in selector.selected_parts:
		selector.part_start_positions[part] = part.global_position - mouse_delta
