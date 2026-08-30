extends Camera2D

var is_dragging = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		# Click
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			
			var zoom_factor: float

			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_factor = 1.1

			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_factor = 0.9

			position += (get_global_mouse_position() - position) * (1.0 - 1.0 / zoom_factor)
			zoom *= zoom_factor
			

	elif event is InputEventMouseMotion:
		# Drag
		if is_dragging:
			position -= event.relative / zoom