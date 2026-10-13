extends RigidBody2D
class_name Spacecraft

var absolute_position_x: float = 0.0
var absolute_position_y: float = 0.0

@onready var universe: Universe = %Universe
@onready var world: SpaceWorld = %World

@export var max_zoom: float = 4.0
@export var min_zoom: float = 0.00001

var camera: Camera2D

func _ready() -> void:
	call_deferred("_find_camera")
	
	linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	linear_damp = 0.0
	
	angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	angular_damp = 0.0

func _find_camera() -> void:
	for child in get_children():
		if child is Camera2D:
			camera = child
			break

func _physics_process(delta: float) -> void:
	absolute_position_x = global_position.x + Global.origin_offset_x
	absolute_position_y = global_position.y + Global.origin_offset_y
	
	var total_gravity_force = Vector2.ZERO
	
	for planet_name in Global.bodies:
		var planet: CelestialBody = Global.bodies[planet_name]
		
		var dir_x = planet.absolute_position_x - absolute_position_x
		var dir_y = planet.absolute_position_y - absolute_position_y
		var direction = Vector2(dir_x, dir_y)
		var distance_sqared = direction.length_squared()
		
		total_gravity_force += direction.normalized() * (
			Constants.G * planet.mass * mass / distance_sqared
		) * (Global.time_scale ** 2)
		
	self.apply_central_force(total_gravity_force)
	
	print("velocity ", linear_velocity)
	print("global ", global_position)
	print("abs ", absolute_position_x, ' ', absolute_position_y)


func _unhandled_input(event: InputEvent) -> void:
	if not camera:
		return
		
	if event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
		if event.is_action_pressed("zoom_in"):
			camera.zoom *= 1.5
		else:
			camera.zoom *= 0.5
		
		camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
		camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
	
