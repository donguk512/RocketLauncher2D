extends Node2D
class_name SpaceWorld

@onready var spacecrafts: Node2D = $Spacecrafts

@export var origin_shift_threshold: float = 10000.0


func _physics_process(delta: float) -> void:
	var active_ship: Spacecraft = spacecrafts.active_ship
	
	if not active_ship:
		return
	
	if active_ship.global_position.length() > origin_shift_threshold:
		Global.origin_offset_x = active_ship.absolute_position_x
		Global.origin_offset_y = active_ship.absolute_position_y
		
