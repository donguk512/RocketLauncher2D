extends Node2D

@onready var universe: Universe = %Universe

@export var min_zoom: float = 5_000_000.0
@export var max_zoom: float = 50_000_000_000.0

var zoom = 500_000_000.0
var offset: Vector2 = Vector2.ZERO
var is_dragging = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_center = get_viewport_rect().size / 2.0
	position = screen_center
	
	pass # Replace with function body.

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
				zoom_factor = clampf(min_zoom / zoom, 0.95, 1.0)
			else:
				zoom_factor = clampf(max_zoom / zoom, 1.0, 1.05)

			position += (get_global_mouse_position() - position) * (1.0 - 1.0 / zoom_factor)
			zoom *= zoom_factor

	elif event is InputEventMouseMotion:
		# Drag
		if is_dragging:
			position += event.relative / Vector2.ONE



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not visible:
		return
	
	var earth = universe.bodies.Earth
	var screen_center = get_viewport_rect().size / 2.0
	position = screen_center - (earth.global_position / zoom)
	queue_redraw()

var orbit_iter: int = 90
		
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
		
		var orbit_points = PackedVector2Array()
		
		for i in range(orbit_iter):
			var pos = planet.calculate_pos(i / float(orbit_iter) * PI * 2.0)
			orbit_points.append(pos / zoom)
			
		orbit_points.append(orbit_points[0])
		
		draw_polyline(orbit_points, Color(1,1,1, 0.5), 1.0)
