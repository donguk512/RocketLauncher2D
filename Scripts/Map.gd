extends Node2D

@onready var universe: Universe = %Universe

@export var min_zoom: float = 100_000.0
@export var max_zoom: float = 50_000_000_000.0

var zoom = 500_000_000.0
var offset: Vector2 = Vector2.ZERO
var is_dragging = false

var planet_orbit_points: Dictionary = {}
var planet_orbit_lines: Dictionary = {}

enum lod {LOW, MID, HIGH}


func _calculate_orbit(planet: CelestialBody, iteration: int) -> PackedVector2Array:
	var points = PackedVector2Array()
	
	for i in range(iteration):
		var pos = planet.calculate_pos(i / float(iteration) * PI * 2.0)
		points.append(pos / min_zoom)
	
	points.append(points[0])
	
	return points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_center = get_viewport_rect().size / 2.0
	position = screen_center
	
	for planet_name: String in universe.bodies:
		var planet: CelestialBody = universe.bodies[planet_name]
		var orbit_line_2d: Line2D = Line2D.new()
		orbit_line_2d.width = 1.0
		orbit_line_2d.default_color = Color(0.187, 0.187, 0.187, 1.0)
		orbit_line_2d.z_index = -1
		
		planet_orbit_points[planet_name] = {
			lod.LOW: _calculate_orbit(planet, 90),
			lod.MID: _calculate_orbit(planet, 360),
			lod.HIGH: _calculate_orbit(planet, 1080) 
		}
		planet_orbit_lines[planet_name] = orbit_line_2d
		
		orbit_line_2d.points = planet_orbit_points[planet_name][lod.LOW]
		add_child(orbit_line_2d)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		self.visible = !self.visible

	if event is InputEventMouseButton:
		# Click
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
			
		elif event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
			var zoom_factor: float = 1.0
			
			if event.is_action_pressed("zoom_in"):
				zoom_factor = clampf(min_zoom / zoom, 0.9, 1.0)
			else:
				zoom_factor = clampf(max_zoom / zoom, 1.0, 1.1)

			position += (get_global_mouse_position() - position) * (1.0 - 1.0 / zoom_factor)
			zoom *= zoom_factor

	elif event is InputEventMouseMotion:
		# Drag
		if is_dragging:
			position += event.relative / Vector2.ONE


func _process(delta: float) -> void:
	if not visible:
		return
	
	var earth = universe.bodies.Earth
	var screen_center = get_viewport_rect().size / 2.0
	# position = screen_center - (earth.global_position / zoom)
		
	queue_redraw()
		
func _draw() -> void:
	for planet_name: String in universe.bodies:
		var planet: CelestialBody = universe.bodies[planet_name]
		
		var radius = max(planet.radius / zoom**2, 3.0)
		
		draw_circle(
			planet.global_position / zoom,
			radius,
			planet.debug_color,
			true
		)
		draw_string(
			ThemeDB.fallback_font, 
			planet.global_position / zoom + Vector2(radius, radius),
			planet_name,
			HORIZONTAL_ALIGNMENT_LEFT, 
			-1,
			14
		)
		
		var screen_size = planet.semi_major_axis / zoom
		var target_lod = lod.LOW
		
		if screen_size > 3000.0:
			target_lod = lod.HIGH
		elif screen_size > 800.0:
			target_lod = lod.MID
		
		var orbit: Line2D = planet_orbit_lines[planet_name]
		
		orbit.scale = Vector2.ONE * min_zoom / zoom
		orbit.width = 1.0 / min_zoom * zoom
		orbit.points = planet_orbit_points[planet_name][target_lod]
		
		if planet.parent_body:
			orbit.position = planet.parent_body.global_position / zoom
		
