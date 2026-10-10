extends Camera2D

@export var max_zoom: float = 4.0;
@export var min_zoom: float = 0.5;

var is_dragging = false
signal zoom_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		# Click
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
			
		elif event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
			var zoom_factor: float = 1.0
			
			if event.is_action_pressed("zoom_in"):
				zoom_factor = clampf(max_zoom / zoom.x, 1.0, 1.1)
			else:
				zoom_factor = clampf(min_zoom / zoom.x, 0.9, 1.0)

			position += (get_global_mouse_position() - position) * (1.0 - 1.0 / zoom_factor)
			zoom *= zoom_factor
			
			zoom_changed.emit()

	elif event is InputEventMouseMotion:
		# Drag
		if is_dragging:
			position -= event.relative / zoom
