extends RigidBody2D
class_name Spacecraft

var absolute_position_x: float = 0.0
var absolute_position_y: float = 0.0

@export var max_zoom: float = 16.0
@export var min_zoom: float = 0.0001

var camera: Camera2D
var throttle: float = 0.0
var parts: Array[PartBase] = []
var stages: Dictionary = {}

func _ready() -> void:
	linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	linear_damp = 0.0
	
	angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	angular_damp = 0.0
	
func initialize(_parts) -> void:
	parts = _parts
	
	for part in parts:
		if part is PartEngine:
			part.get_linked_tanks()
			
		if part.stage_index == -1:
			continue
		
		if not stages.get(part.stage_index):
			stages[part.stage_index] = []
			
		stages[part.stage_index].append(part)
	
	camera = Camera2D.new()
	camera.ignore_rotation = false
	
	add_child(camera)

func _calc_gravity(body: CelestialBody, x: float, y: float) -> Vector2:
	var dx = (body.absolute_position_x - absolute_position_x) / Constants.GRID_SIZE_BIG
	var dy = (body.absolute_position_y - absolute_position_y) / Constants.GRID_SIZE_BIG
		
	var distance_squared = dx*dx + dy*dy
	var direction = Vector2(dx, dy)
	
	return direction.normalized() * (
		Constants.G * body.mass / distance_squared) * (Global.time_scale ** 2)


func _physics_process(delta: float) -> void:
	var frame_body: CelestialBody = Global.frame_body
	var acceleration := Vector2.ZERO
	
	absolute_position_x = (
		frame_body.absolute_position_x + global_position.x + Global.origin_offset_x)
	absolute_position_y = (
		frame_body.absolute_position_y + global_position.y + Global.origin_offset_y)
	
	for planet_name in Global.bodies:
		var planet: CelestialBody = Global.bodies[planet_name]
		acceleration += _calc_gravity(planet, absolute_position_x, absolute_position_y)
		
		if planet != frame_body:
			acceleration -= _calc_gravity(
				planet, frame_body.absolute_position_x, frame_body.absolute_position_y)
				# tidal only
	
	self.apply_central_force(acceleration * mass)
	
	for part in parts:
		if part.get("process_part_physics"):
			part.process_part_physics(self, delta)

func _process(delta: float) -> void:
	var frame_body: CelestialBody = Global.frame_body
	
	camera.global_rotation = - (
		camera.global_position - frame_body.global_position).angle()

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
	
