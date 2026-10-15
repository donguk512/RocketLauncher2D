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
	var dx = (body.absolute_position_x - absolute_position_x) / Constants.PIXELS_PER_METER
	var dy = (body.absolute_position_y - absolute_position_y) / Constants.PIXELS_PER_METER
		
	var distance_squared = dx*dx + dy*dy
	var direction = Vector2(dx, dy).normalized()
	var accel = (Constants.G * body.mass / distance_squared) * (Global.time_scale ** 2)
	
	return direction * accel * Constants.PIXELS_PER_METER


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


func separate_parts_from(decoupler: PartBase, force: float) -> void:
	var to_detach: Array[PartBase] = []
	var unvisited: Array[PartBase] = []
	
	for neighbor in decoupler.get_neighbors():
		if neighbor.position.y > decoupler.position.y:
			unvisited.append(neighbor)
			
	var visited = []
	while not unvisited.is_empty():
		var current = unvisited.pop_back()
		visited.append(current)
		to_detach.append(current)
		
		for neighbor in current.get_neighbors():
			if neighbor == decoupler or neighbor in visited or neighbor in unvisited:
				continue
			unvisited.append(neighbor)
			
	if to_detach.is_empty():
		return
		
	var debris: Spacecraft = load("res://Scenes/Spacecraft.tscn").instantiate()
	get_parent().add_child(debris)
	
	debris.global_position = global_position
	debris.global_rotation = global_rotation
	debris.linear_velocity = linear_velocity
	debris.angular_velocity = angular_velocity
	
	for part in to_detach:
		parts.erase(part)
		part.reparent(debris, false) 
		
		for child in get_children():
			if child is CollisionShape2D and child.position.is_equal_approx(part.position):
				child.reparent(debris, false)
				break
				
	self.recalculate_mass_com()
	debris.parts = to_detach
	debris.recalculate_mass_com()
	
	var push_dir := -global_transform.y.normalized()
	
	apply_impulse(push_dir * force, decoupler.global_position - global_position)
	debris.apply_impulse(-push_dir * force, decoupler.global_position - debris.global_position)
	
	parts.erase(decoupler)
	debris.parts.erase(decoupler)
	
	for child in get_children():
		if child is CollisionShape2D and child.position.is_equal_approx(decoupler.position):
			child.queue_free()
			break
			
	decoupler.queue_free()
	self.recalculate_mass_com()

func recalculate_mass_com() -> void:
	var total_mass := 0.0
	var com := Vector2.ZERO
	
	for part in parts:
		total_mass += part.mass
		com += part.position * part.mass
		
	if total_mass > 0.0:
		self.mass = total_mass
		self.center_of_mass = com / total_mass
	
	if camera:
		camera.global_position = VABTransform.get_aabb(parts).get_center()


func _process(delta: float) -> void:
	if not is_instance_valid(camera):
		return
	
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
	
