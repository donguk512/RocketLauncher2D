extends Node2D

@onready var catalog: Panel = $UI/CatalogPanel
@onready var builder: Node2D = $Builder
@onready var camera: Camera2D = $Camera
@onready var grid: ColorRect = $GridCanvas/Grid
@onready var workspace: Node2D = %Workspace
@onready var blueprint: Blueprint = $BlueprintIO

@export var blueprint_name: String = "제목 없는 청사진"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	catalog.part_selected.connect(builder.spawn_part)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mat = grid.material as ShaderMaterial
	mat.set_shader_parameter("camera_position", camera.global_position)
	mat.set_shader_parameter("zoom", camera.zoom)

func _on_save_blueprint_pressed() -> void:
	
	var parts: Array[PartBase] = []
	
	for part in workspace.get_children():
		if part is not PartBase:
			continue
		parts.append(part)
		
	blueprint.prompt_save(parts)

func _on_load_blueprint_pressed() -> void:
	blueprint.prompt_load()
	
	await get_tree().process_frame
	
	var all_snaps = get_tree().get_nodes_in_group("snap_point")
	
	for child in workspace.get_children():
		if child is PartBase:
			SnapSolver.link_sockets([child], all_snaps)


func _on_launch_pressed() -> void:
	var all_parts: Array[PartBase] = []
	
	for part in workspace.get_children():
		if part is PartBase:
			all_parts.append(part)
	
	var clusters = blueprint.group_linked_parts(
		all_parts, get_world_2d().direct_space_state
	)
	
	clusters.sort_custom(func(a, b):
		return a.size() > b.size()
	)
	
	for cluster in clusters:
		Global.launch_blueprints.append(
			blueprint.make_list(cluster)
		)
	
	get_tree().change_scene_to_file("res://Scenes/Ingame.tscn")
