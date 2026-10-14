class_name PartEngine
extends PartBase

@export var max_thrust: float = 500.0

var ignited := false



func process_part_physics(ship: Spacecraft, delta: float) -> void:
	if not ignited or ship.throttle <= 0.0:
		return
	
	var direction := -global_transform.y.normalized()
	var force := direction * (max_thrust * ship.throttle)
	var force_pos := global_position - ship.global_position
	
	ship.apply_force(force, force_pos)
