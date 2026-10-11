extends Node

@onready var workspace: Node2D = %Workspace

const TOLERANCE_VECTOR: Vector2 = Vector2.ONE * 1.05

func group_linked_parts(
	all_parts: Array[PartBase],
	space_state: PhysicsDirectSpaceState2D
) -> Array[Array]:

	var clusters: Array[Array] = []
	var unvisited: Array[PartBase] = all_parts.duplicate()
	
	while unvisited.size() > 0:
		var start_part: PartBase = unvisited.pop_back()
		var this_cluster: Array[PartBase] = [start_part]
		var queue: Array[PartBase] = [start_part]
		
		while queue.size() > 0:
			var this_part: PartBase = queue.pop_front()
			var collision_shape = this_part.collision_shape
			
			var params = PhysicsShapeQueryParameters2D.new()
			params.shape = collision_shape.shape
			params.transform = collision_shape.global_transform.scaled_local(
				TOLERANCE_VECTOR
			)
			params.collide_with_areas = true
			params.collide_with_bodies = false
			
			var neighbors: Array[PartBase] = []
			
			for socket in this_part.get_snap_points():
				if socket.linked_point:
					var linked_part: PartBase = socket.linked_point.part
					neighbors.append(linked_part)
					params.exclude.append(linked_part.area.get_rid())
			
			var hits = space_state.intersect_shape(params)
			for hit in hits:
				var collider = hit.collider
				if collider is Area2D and collider.get_parent() is PartBase:
					neighbors.append(collider.get_parent() as PartBase)
			
			
			for neighbor in neighbors:
				var idx = unvisited.find(neighbor)
				
				if idx != -1:
					unvisited.remove_at(idx)
					this_cluster.append(neighbor)
					queue.append(neighbor)
			
		clusters.append(this_cluster)
		
	return clusters


func make_list(parts: Array[PartBase]) -> Array:
	var blueprint_data: Array = []
	
	for part: PartBase in parts:
		blueprint_data.append({
			"type": part.part_name,
			"x": int(part.global_position.x),
			"y": int(part.global_position.y),
			"r": int(part.rotation / PI * 2)
		})
	
	return blueprint_data



func prompt_save(parts: Array[PartBase]) -> void:
	var data = make_list(parts)
	
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_USERDATA
	dialog.clear_filters()
	dialog.add_filter("*.json", "청사진 파일")
	dialog.use_native_dialog = true
	
	dialog.file_selected.connect(func(path: String):
		_save_to_path(path, data)
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func(): dialog.queue_free())
	
	add_child(dialog)
	dialog.popup_centered(Vector2(600, 400))

func prompt_load() -> void:
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_USERDATA
	dialog.clear_filters()
	dialog.add_filter("*.json", "청사진 파일")
	dialog.use_native_dialog = true
	
	dialog.file_selected.connect(func(path: String):
		_load_from_path(path)
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func(): dialog.queue_free())
	
	add_child(dialog)
	dialog.popup_centered(Vector2(600, 400))


func _save_to_path(path: String, data: Array) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		var json_string = JSON.stringify(data, "\t", false)
		file.store_string(json_string)
		file.close()
		print("Saved blueprint at: ", path)
	else:
		printerr("Cannot save file: ", path)

func _load_from_path(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var success = json.parse(json_string)
		
		file.close()
		
		if success == OK:
			var blueprint_data = json.data
			print("Successfully loaded blueprint!: ", path)
			
			_spawn_parts(blueprint_data)
	else:
		printerr("Cannot open file: ", path)
	return {}


func _spawn_parts(blueprint) -> void:
	for part_data in blueprint:
		var part_scene: PackedScene = PartDB.part_names.get(part_data.type)
		
		if not part_scene:
			printerr("Undefined part type: ", part_data.type)
			continue
		
		var new_part: PartBase = part_scene.instantiate()
		new_part.global_position = Vector2(
			part_data.x, part_data.y
		)
		new_part.rotation = part_data.r * PI / 2
		
		workspace.add_child(new_part)
