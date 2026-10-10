extends Node2D

@onready var catalog: Panel = $UI/CatalogPanel
@onready var builder: Node2D = $Builder
@onready var camera: Camera2D = $Camera
@onready var grid: ColorRect = $GridCanvas/Grid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	catalog.part_selected.connect(builder.spawn_part)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mat = grid.material as ShaderMaterial
	mat.set_shader_parameter("camera_position", camera.global_position)
	mat.set_shader_parameter("zoom", camera.zoom)

func _on_launch_pressed() -> void:
	var rocket = RigidBody2D.new()
	
	var parts = builder.selector.get_children()
