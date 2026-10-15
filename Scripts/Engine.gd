class_name PartEngine
extends PartBase

@export var max_thrust: float = 500000.0
@onready var flame: GPUParticles2D = $Flame

var ignited := false

func enable():
	print("ignited!")
	ignited = true
	flame.emitting = true
	
func disable():
	ignited = false
	flame.emitting = false

func process_part_physics(ship: Spacecraft, delta: float) -> void:
	if not ignited or ship.throttle <= 0.0:
		return
	
	var direction := -global_transform.y.normalized()
	var force := direction * (max_thrust * ship.throttle)
	var force_pos := global_position - ship.global_position
	
	var material := flame.process_material as ParticleProcessMaterial
	material.initial_velocity_min = ship.throttle
	material.initial_velocity_max = ship.throttle * 2.0
	
	ship.apply_force(force, force_pos)
	print(force, force_pos)
