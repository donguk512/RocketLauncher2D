extends Node2D

const spacecraft = preload("res://Scenes/Spacecraft.tscn")
@onready var universe: Universe = %Universe

var active_ship: RigidBody2D = null

func _ready() -> void:
	for i in range(30):
		await get_tree().physics_frame
	
	var earth: CelestialBody = Global.bodies.Earth
	var blueprints = Global.launch_blueprints
	var clusters: Array = []
	
	for blueprint in blueprints:
		var spacecraft: Spacecraft = spacecraft.instantiate()
		
		spacecraft.absolute_position_x = earth.absolute_position_x 
		spacecraft.absolute_position_y = earth.absolute_position_y + earth.radius + 10000
		
		add_child(spacecraft)
		
		var parts = Blueprint.spawn_parts(blueprint, spacecraft)
		var center_of_mass: Vector2 = Vector2.ZERO
		
		for part: PartBase in parts:
			var original_shape = part.get_node("Area/CollisionShape")
			
			if original_shape:
				var physics_shape = CollisionShape2D.new()
				physics_shape.shape = original_shape.shape
				physics_shape.position = part.position
				physics_shape.rotation = part.rotation
				
				spacecraft.add_child(physics_shape)
			
			center_of_mass += part.position * part.mass
		
		center_of_mass /= parts.size()
		
		for child in spacecraft.get_children():
			if child is Node2D and not child is Camera2D:
				child.position -= center_of_mass
				
		clusters.append(spacecraft)
	
	active_ship = clusters[0]
	
	Global.origin_offset_x = active_ship.absolute_position_x
	Global.origin_offset_y = active_ship.absolute_position_y
	
	var new_transform = active_ship.global_transform
	new_transform.origin = Vector2.ZERO
	
	PhysicsServer2D.body_set_state(active_ship.get_rid(), 
		PhysicsServer2D.BODY_STATE_TRANSFORM, new_transform
	)
	
	
	var camera = Camera2D.new()
	# camera.position_smoothing_enabled = true
	
	active_ship.add_child(camera)
	camera.make_current()
	
	active_ship.linear_velocity = earth.velocity
	print("velo: ", active_ship.linear_velocity)
