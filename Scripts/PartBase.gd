class_name PartBase
extends Node2D

@export var mass: float = 1.0
@export var icon: Texture2D
@export var part_name: String = "unknown_part"

@onready var area: Area2D = $Area
@onready var collision_shape: CollisionShape2D = $Area/CollisionShape

var highlighted: bool = false
var stage_index: int = -1

func _ready() -> void:
	pass
	
func get_snap_points() -> Array[SnapPoint]:
	var points: Array[SnapPoint] = []
	
	for child in $SnapPoints.get_children():
		if child is SnapPoint:
			points.append(child)
			
	return points
	
func get_neighbors() -> Array[PartBase]:
	var neighbors: Array[PartBase] = []
	
	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = collision_shape.shape
	params.transform = collision_shape.global_transform.scaled_local(
		Vector2(1.025, 1.025)
	)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	for socket in get_snap_points():
		if socket.linked_point:
			var linked_part: PartBase = socket.linked_point.part
			neighbors.append(linked_part)
			params.exclude.append(linked_part.area.get_rid())
	
	var hits = get_world_2d().direct_space_state.intersect_shape(params)
	for hit in hits:
		var collider = hit.collider
		if collider is Area2D and collider.get_parent() is PartBase:
			neighbors.append(collider.get_parent() as PartBase)
	
	return neighbors

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
		
		draw_rect(rect, Color(1.0, 1.0, 1.0, 1.0), false, 2.0 / zoom)
