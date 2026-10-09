class_name PartBase
extends Node2D

@export var mass: float = 1.0
@export var icon: Texture2D

@onready var area: Area2D = $Area

func get_snap_points():
	var points: Array[SnapPoint] = []
	
	for child in $SnapPoints.get_children():
		if child is SnapPoint:
			points.append(child)
			
	return points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
