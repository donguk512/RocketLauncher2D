class_name PartBase
extends Node2D

@export var mass: float = 1.0
@export var icon: Texture2D
@export var part_name: String = "unknown_part"

@onready var area: Area2D = $Area
@onready var collision_shape: CollisionShape2D = $Area/CollisionShape

var highlighted: bool = false

func _ready() -> void:
	pass
	
func get_snap_points() -> Array[SnapPoint]:
	var points: Array[SnapPoint] = []
	
	for child in $SnapPoints.get_children():
		if child is SnapPoint:
			points.append(child)
			
	return points

func highlight():
	highlighted = true
	z_index = 1
	queue_redraw()
	
func unhighlight():
	highlighted = false
	z_index = 0
	queue_redraw()

func _draw() -> void:
	if highlighted:
		var zoom = get_viewport().get_camera_2d().zoom.x
		var rect = collision_shape.shape.get_rect().grow(1.0 / zoom)
		
		draw_rect(rect, Color(1.0, 0.0, 1.0, 1.0), false, 2.0 / zoom)
