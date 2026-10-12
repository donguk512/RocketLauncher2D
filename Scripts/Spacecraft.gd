extends RigidBody2D
class_name Spacecraft

var absolute_position: Vector2 = Vector2.ZERO

@onready var universe: Universe = %Universe
@onready var world: SpaceWorld = %World


func _physics_process(delta: float) -> void:
	absolute_position = global_position + Global.origin_offset
	
	var total_gravity_force = Vector2.ZERO
	
	for planet_name in Global.bodies:
		var planet: CelestialBody = Global.bodies[planet_name]
		
		var direction = planet.absolute_position - absolute_position
		var distance_sqared = direction.length_squared()
		
		total_gravity_force += direction.normalized() * (
			Constants.G * planet.mass * mass / distance_sqared
		)
	
	# self.apply_central_force(total_gravity_force)
	
	
	
		
