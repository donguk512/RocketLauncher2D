extends Node2D
class_name CelestialBody

@onready var collision_shape: CollisionShape2D = $Ground/CollisionShape2D

var mass: float
var radius: float
var soi_radius: float
var absolute_position_x: float
var absolute_position_y: float
var absolute_position: Vector2:
	get: return Vector2(absolute_position_x, absolute_position_y)

var parent_body: CelestialBody
var semi_major_axis: float
var eccentricity: float
var arg_of_periapsis: float
var mean_anomaly_epoch: float

var debug_color: Color = Color(1,1,1)

var mu: float
var mean_motion: float
var velocity: Vector2 = Vector2.ZERO

var _last_absolute_x: float = 0.0
var _last_absolute_y: float = 0.0

var num_points: int = 120
var points: Array[Vector2] = []

func _ready():
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision_shape.shape = shape
	
	for i in range(num_points):
		var angle = i * PI * 2.0 / num_points
		points.append(
			Vector2(cos(angle), sin(angle)) * radius
		)
	
func init():
	if parent_body:
		mu = Constants.G * parent_body.mass
		mean_motion = sqrt(mu / semi_major_axis ** 3)

func _draw():
	draw_polygon(points, PackedColorArray([debug_color]))

func calculate_pos(theta: float) -> Array:
	if not parent_body: # When it's sun
		return [0.0, 0.0]
	
	# Update Mean Anomaly
	var mean_anomaly = fmod(theta, PI * 2.0)
	
	# Calculating approximate Eccentric Anomaly
	var E: float = mean_anomaly
	
	# M = E - e sin(E)
	# Newton-Raphson
	for i in range(Constants.KEPLER_ITERATION):
		E -= (
			E - eccentricity * sin(E) - mean_anomaly
			) / (
			1 - eccentricity * cos(E)
		)
	
	var x = semi_major_axis * (cos(E) - eccentricity)
	var y = semi_major_axis * sqrt(1 - eccentricity ** 2) * sin(E)
	
	var sin_omega = sin(arg_of_periapsis)
	var cos_omega = cos(arg_of_periapsis)
	
	var x_rotated = x * cos_omega - y * sin_omega
	var y_rotated = x * sin_omega + y * cos_omega
	
	return [x_rotated, y_rotated]

func _physics_process(delta: float) -> void:
	var parent_offset_x: float = 0.0
	var parent_offset_y: float = 0.0
	
	if parent_body:
		parent_offset_x = parent_body.absolute_position_x
		parent_offset_y = parent_body.absolute_position_y
	
	var pos = calculate_pos(mean_anomaly_epoch + mean_motion * Global.time)
	absolute_position_x = pos[0] + parent_offset_x
	absolute_position_y = pos[1] + parent_offset_y
	
	global_position = Vector2(
		absolute_position_x - Global.origin_offset_x,
		absolute_position_y - Global.origin_offset_y
	) 
	
	velocity = Vector2(
		pos[0] - _last_absolute_x,
		pos[1] - _last_absolute_y
	) / delta
	
	_last_absolute_x = pos[0]
	_last_absolute_y = pos[1]
	
	queue_redraw()
