extends Node2D

const spacecraft = preload("res://Scenes/Spacecraft.tscn")
@onready var universe: Universe = %Universe

var active_ship: RigidBody2D = null

func _ready() -> void:
	await get_tree().process_frame
	
	var blueprints = Global.launch_blueprints
	var clusters: Array = []
	
	for blueprint in blueprints:
		var spacecraft: Spacecraft = spacecraft.instantiate()
		add_child(spacecraft)
		
		await Blueprint.spawn_parts(blueprint, spacecraft)
		
		var earth: CelestialBody = Global.bodies.Earth
		
		spacecraft.absolute_position = earth.absolute_position + (
			Vector2.UP * earth.radius
		)
		
		clusters.append(spacecraft)
	
	active_ship = clusters[0]
	
	active_ship.global_position = Vector2.ZERO
	
	Global.origin_offset = active_ship.absolute_position
	
	var camera = Camera2D.new()
	# camera.position_smoothing_enabled = true
	
	active_ship.add_child(camera)
	camera.make_current()
