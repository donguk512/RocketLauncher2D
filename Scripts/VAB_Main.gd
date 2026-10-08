extends Node2D

@onready var part_grid: GridContainer = $UI.get_node("%PartGrid")
@onready var workspace: Node2D = $Workspace

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	part_grid.part_selected.connect($Workspace.spawn_part)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_launch_pressed() -> void:
	var rocket = RigidBody2D.new()
	
	var parts = workspace.get_children()
	for 
