extends Node2D

@onready var catalog: Panel = $UI/CatalogPanel
@onready var builder: Node2D = $Builder
@onready var camera: Camera2D = $Camera
@onready var grid: ColorRect = $GridCanvas/Grid
@onready var workspace: Node2D = $Builder/Selector/Workspace
@onready var blueprint: Node = $BlueprintIO

@export var blueprint_name: String = "제목 없는 청사진"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	catalog.part_selected.connect(builder.spawn_part)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mat = grid.material as ShaderMaterial
	mat.set_shader_parameter("camera_position", camera.global_position)
	mat.set_shader_parameter("zoom", camera.zoom)

func _on_launch_pressed() -> void:
	var rocket = RigidBody2D.new()

func _on_save_blueprint_pressed() -> void:
	
	var parts: Array[PartBase] = []
	
	for part in workspace.get_children():
		if part is not PartBase:
			continue
		parts.append(part)
		
	blueprint.prompt_save(parts)


func _on_load_blueprint_pressed() -> void:
	blueprint.prompt_load()
