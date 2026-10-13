extends Node
class_name Blueprint

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
			"r": int(part.rotation / PI * 4)
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
		JsonIO.save_to_path(path, data)
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
		dialog.queue_free()
		
		var blueprint_data = JsonIO.load_from_path(path)
		spawn_parts(blueprint_data, workspace)
	)
	
	dialog.canceled.connect(func(): dialog.queue_free())
	
	add_child(dialog)
	dialog.popup_centered(Vector2(600, 400))


static func spawn_parts(blueprint, parent: Node) -> Array[PartBase]:
	var added_parts: Array[PartBase] = []
	
	for part_data in blueprint:
		var part_scene: PackedScene = PartDB.part_names.get(part_data.type)
		
		if not part_scene:
			printerr("Undefined part type: ", part_data.type)
			continue
		
		var new_part: PartBase = part_scene.instantiate()
		new_part.global_position = Vector2(
			part_data.x, part_data.y
		)
		new_part.rotation = part_data.r * PI / 4
		
		parent.add_child(new_part)
		added_parts.append(new_part)
		
	return added_parts
