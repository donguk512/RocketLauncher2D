extends Node2D

const spacecraft = preload("res://Scenes/Spacecraft.tscn")
@onready var universe: Universe = %Universe
@onready var world: SpaceWorld = %World

var active_ship: Spacecraft = null

func _ready() -> void:
	for i in range(30):
		await get_tree().physics_frame
	
	var earth: CelestialBody = Global.bodies.Earth
	
	var blueprints = Global.launch_blueprints
	var clusters: Array = []
	
	
	for blueprint in blueprints:
		var ship: Spacecraft = spacecraft.instantiate()
		
		var parts = Blueprint.spawn_parts(blueprint, ship)
		var center_of_mass: Vector2 = Vector2.ZERO
		var total_mass: float = 0.0
		
		for part: PartBase in parts:
			var original_shape = part.get_node("Area/CollisionShape")
			
			if original_shape:
				var physics_shape = CollisionShape2D.new()
				physics_shape.shape = original_shape.shape
				physics_shape.position = part.position
				physics_shape.rotation = part.rotation
				
				ship.add_child(physics_shape)
			
			center_of_mass += part.position * part.mass
			total_mass += part.mass
		
		center_of_mass /= total_mass
		ship.mass = total_mass
		
		for child in ship.get_children():
			if child is Node2D and not child is Camera2D:
				child.position -= center_of_mass
				
		ship.absolute_position_x = earth.absolute_position_x 
		ship.absolute_position_y = earth.absolute_position_y - earth.radius - 64.0
		
		add_child(ship)
		
		ship.global_position = Vector2.ZERO
		
		var frame_body := Global.frame_body
		Global.origin_offset_x = (
			ship.absolute_position_x - frame_body.absolute_position_x
		)
		Global.origin_offset_y = (
			ship.absolute_position_y - frame_body.absolute_position_y
		)
		
		clusters.append(ship)
	
	active_ship = clusters[0]
	
	var camera = Camera2D.new()
	active_ship.add_child(camera)
	camera.make_current()
	
