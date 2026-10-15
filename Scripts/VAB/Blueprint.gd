extends Node
class_name Blueprint

@onready var workspace: Node2D = %Workspace
@onready var stage_ui: StageUI = $"../UI/Stages"

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
			
			var neighbors := this_part.get_neighbors()
			
			for neighbor in neighbors:
				var idx = unvisited.find(neighbor)
				
				if idx != -1:
					unvisited.remove_at(idx)
					this_cluster.append(neighbor)
					queue.append(neighbor)
			
		clusters.append(this_cluster)
		
	return clusters


func serialize(parts: Array[PartBase]) -> Array:
	var blueprint_data := []
	
	var aabb := VABTransform.get_aabb(parts)
	var pivot = aabb.position + aabb.size * Vector2(0.5, 1.0)
	
	for part: PartBase in parts:
		var part_data := {
			"type": part.part_name,
			"x": int((part.global_position - pivot).x),
			"y": int((part.global_position - pivot).y),
			"r": int(part.rotation / PI * 4),
		}
		if part.get("stage_index") != null:
			part_data.stage = part.stage_index
		
		blueprint_data.append(part_data)
	
	return blueprint_data



func prompt_save(parts: Array[PartBase], stages: Array) -> void:
	var data = serialize(parts)
	
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
	
	for part_data: Dictionary in blueprint:
		var part_scene: PackedScene = PartDB.part_names.get(part_data.type)
		
		if not part_scene:
			printerr("Undefined part type: ", part_data.type)
			continue
		
		var new_part: PartBase = part_scene.instantiate()
		new_part.global_position = Vector2(
			part_data.x, part_data.y
		)
		new_part.rotation = part_data.r * PI / 4
		new_part.stage_index = part_data.get("stage", -1) 
		
		parent.add_child(new_part)
		added_parts.append(new_part)
		
	return added_parts
