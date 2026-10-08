extends Camera2D

@onready var grid: ColorRect = $"../GridCanvas/Grid"

var is_dragging = false

@export var max_zoom = 4.0;
@export var min_zoom = .5;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mat = grid.material as ShaderMaterial
	mat.set_shader_parameter("camera_position", global_position)
	mat.set_shader_parameter("zoom", zoom)


func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		# Click
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			
			var zoom_factor: float

			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_factor = clampf(max_zoom / zoom.x, 1.0, 1.1)

			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_factor = clampf(min_zoom / zoom.x, 0.9, 1.0)

			position += (get_global_mouse_position() - position) * (1.0 - 1.0 / zoom_factor)
			zoom *= zoom_factor
			

	elif event is InputEventMouseMotion:
		# Drag
		if is_dragging:
			position -= event.relative / zoom
