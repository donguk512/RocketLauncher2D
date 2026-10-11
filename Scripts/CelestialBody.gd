extends Node2D
class_name CelestialBody

@export var mass: float
@export var radius: float
@export var soi_radius: float

@export var parent_body: Node2D
@export var semi_major_axis: float
@export var eccentricity: float
@export var arg_of_periapsis: float
@export var mean_anomaly_epoch: float

@export var debug_color: Color = Color(1,1,1)

var mu: float
var mean_motion: float

func _ready():
	pass
	
func init():
	if parent_body:
		mu = Constants.G * parent_body.mass
		mean_motion = sqrt(mu / semi_major_axis ** 3)
		print(name, " ", PI * 2.0 / mean_motion)

func _draw():
	draw_circle(
		global_position - Vector2.ONE * radius,
		radius,
		Color(1,1,1),
		true
	)

func calculate_pos(theta: float) -> Vector2:
	if not parent_body: # When it's sun
		return Vector2.ONE
	
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
	
	var local_pos = Vector2(x, y).rotated(arg_of_periapsis)
	return parent_body.global_position + local_pos

func _process(delta):
	if not parent_body:
		return
	
	var pos = calculate_pos(mean_anomaly_epoch + mean_motion * Global.time)
	global_position = pos
	
	queue_redraw()
