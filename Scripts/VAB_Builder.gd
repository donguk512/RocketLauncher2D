extends Node2D

var held_part: PartBase
var drag_offset = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

func spawn_part(part_scene: PackedScene) -> void:
	var new_part = part_scene.instantiate()
		
	add_child(new_part)
	
	new_part.clicked.connect(on_part_click)
	held_part = new_part
				

func on_part_click(part: PartBase):
	if held_part == part:
		held_part = null
	else:
		# Start dragging
		drag_offset = part.global_position - get_global_mouse_position()
		held_part = part
		
	print(part)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if held_part != null:
		held_part.global_position = get_global_mouse_position() + drag_offset
