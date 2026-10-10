extends Button

# var assigned_part: PackedScene

func setup(part_scene):
	# assigned_part = part_scene
	var temp_part = part_scene.instantiate()
	
	$Icon.texture = temp_part.icon
	temp_part.queue_free()
