extends Button

# var assigned_part: PackedScene

func setup(part_scene):
	# assigned_part = part_scene
	var temp_part = part_scene.instantiate()
	
	$Icon.texture = temp_part.icon
	temp_part.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
