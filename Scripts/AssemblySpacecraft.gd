extends Node2D

const spacecraft = preload("res://Scenes/Spacecraft.tscn")

@onready var stage_ui: StageUI = $"../../UI/Stages"

@onready var universe: Universe = %Universe
@onready var world: SpaceWorld = %World

var active_ship: Spacecraft = null

func _ready() -> void:
	for i in range(30):
		await get_tree().physics_frame
	
	var earth: CelestialBody = Global.bodies.Earth
	var blueprint = Global.launch_blueprint
	var spawn_theta := -PI/4.0
	
	var spawn_offset := Vector2.from_angle(spawn_theta) * (earth.radius + 8.0)
	
	Global.origin_offset_x = spawn_offset.x
	Global.origin_offset_y = spawn_offset.y
	
	var ship: Spacecraft = spacecraft.instantiate()
	var parts = Blueprint.spawn_parts(blueprint, ship)
	var center_of_mass: Vector2 = Vector2.ZERO
	var total_mass: float = 0.0
	var stages = []
	
	ship.rotate(-spawn_theta)
	
	for part in parts:
		var original_shape = part.get_node("Area/CollisionShape")
		
		if original_shape:
			var physics_shape = CollisionShape2D.new()
			physics_shape.shape = original_shape.shape
			physics_shape.position = part.position
			physics_shape.rotation = part.rotation
			
			ship.add_child(physics_shape)
		
		center_of_mass += part.position * part.mass
		total_mass += part.mass
		
		ship.center_of_mass = center_of_mass / total_mass
		ship.mass = total_mass
		
		print(stages)
		print(part.stage_index)
		if part.stage_index != -1 and not part.stage_index in stages:
			stages.append(part.stage_index)
			stage_ui.make_stage()
		
	add_child(ship)
	
	var camera = Camera2D.new()
	ship.add_child(camera)
	camera.make_current()
	
	stage_ui.refresh_stage_icons(parts)
