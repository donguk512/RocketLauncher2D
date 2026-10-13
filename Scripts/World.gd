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
		
		for ship in spacecrafts.get_children():
			if ship is Spacecraft:
				var ship_t = ship.global_transform
				ship_t.origin -= active_ship.global_position
				PhysicsServer2D.body_set_state(ship.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, ship_t)
