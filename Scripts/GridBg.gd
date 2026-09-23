extends Color

@export var grid_size: float = 32.0
@export var grid_color: Color = Color(1, 1, 1, 0.15)
@export var line_width: float = 1.0

@export var area_size: Vector2 = Vector2(1024, 1024)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw() -> void:
	var half_w = area_size.x / 2.0
	var half_h = area_size.y / 2.0
	
	var x = -half_w
	var y = -half_h
	
	while x <= half_w:
		draw_line(Vector2(x, -half_h), Vector2(x, half_h), grid_color, line_width)
		x += grid_size
		
	while y <= half_h:
		draw_line(Vector2(-half_w, y), Vector2(half_w, y), grid_color, line_width)
		y += grid_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
