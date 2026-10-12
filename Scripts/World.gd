extends Node2D
class_name SpaceWorld

@onready var spacecrafts: Node2D = $Spacecrafts

@export var origin_shift_threshold: float = 10000.0


func _physics_process(delta: float) -> void:
	var active_ship: Spacecraft = spacecrafts.active_ship
	
	if not active_ship:
		return
	
	print("ABS: ", active_ship.absolute_position)
	print("GLO: ", active_ship.global_position)
	print("OFS: ", Global.origin_offset)
	
	if active_ship.global_position.length() > origin_shift_threshold:
		Global.origin_offset = active_ship.absolute_position
