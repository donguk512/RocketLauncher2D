class_name PartEngine
extends PartBase

@export var max_thrust: float = 500000.0
@onready var flame: GPUParticles2D = $Flame

var ignited := false
var linked_fuel_tanks = []
var tank_count := 0

func enable():
	print("ignited!")
	ignited = true
	flame.emitting = true
	
func disable():
	ignited = false
	flame.emitting = false

func get_linked_tanks() -> void:
	var unvisiteds := get_neighbors()
	var visiteds := [self]
	var tanks = []
	
	while not unvisiteds.is_empty():
		var part: PartBase = unvisiteds.pop_back()
		visiteds.append(part)
		tanks.append(part)
		
		for neighbor in part.get_neighbors():
			if neighbor is not FuelTank:
				continue
			unvisiteds.append(neighbor)
	
	linked_fuel_tanks = tanks
	tank_count = linked_fuel_tanks.size()

func process_part_physics(ship: Spacecraft, delta: float) -> void:
	if not ignited or ship.throttle <= 0.0:
		return
	
	var goal_thrust := max_thrust * ship.throttle
	var goal_fuel := (goal_thrust / Constants.THRUST_PER_FUEL) * delta
	var total_fuel := 0.0
	
	for tank: FuelTank in linked_fuel_tanks:
		total_fuel += tank.fuel_mass
	
	print(goal_fuel, " / ", total_fuel)
	
	var fuel_to_consume := minf(total_fuel, goal_fuel)
		
	for tank: FuelTank in linked_fuel_tanks:
		tank.drain(fuel_to_consume / total_fuel)
		
	var thrust = fuel_to_consume / delta * Constants.THRUST_PER_FUEL
	
	var direction := -global_transform.y.normalized()
	var force = direction * thrust
	var force_pos := global_position - ship.global_position
	
	var material := flame.process_material as ParticleProcessMaterial
	material.initial_velocity_min = ship.throttle
	material.initial_velocity_max = ship.throttle * 2.0
	
	ship.apply_force(force, force_pos)
	print(force, force_pos)
	
