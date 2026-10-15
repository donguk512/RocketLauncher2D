extends Node2D
class_name CelestialBody

@onready var collision_shape: CollisionShape2D = $Ground/CollisionShape2D
@onready var ground: StaticBody2D = $Ground
@onready var polygon: Polygon2D = $Polygon2D

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

var local_x: float = 0.0
var local_y: float = 0.0



func _ready():
	var surface := SurfaceArc.new()
	surface.body = self
	surface.color = debug_color
	
	add_child(surface)
	_setup_collider()
	
func init():
	if parent_body:
		mu = Constants.G * parent_body.mass
		mean_motion = sqrt(mu / semi_major_axis ** 3)


func _physics_process(delta: float) -> void:
	
	var parent_offset_x := 0.0
	var parent_offset_y := 0.0
	
	if parent_body:
		parent_offset_x = parent_body.absolute_position_x
		parent_offset_y = parent_body.absolute_position_y
	
	var pos = OrbitMath.calculate_pos(
		mean_anomaly_epoch + mean_motion * Global.time,
		eccentricity,
		semi_major_axis,
		arg_of_periapsis,
		4
	)
	absolute_position_x = pos[0] + parent_offset_x
	absolute_position_y = pos[1] + parent_offset_y
	
	var frame_body := Global.frame_body
	
	local_x = absolute_position_x - frame_body.absolute_position_x - Global.origin_offset_x
	local_y = absolute_position_y - frame_body.absolute_position_y - Global.origin_offset_y
	
	global_position = Vector2(local_x, local_y)   # still used by the collider
	
	if _last_absolute_x != 0.0:
		var relative := Vector2(
			pos[0] - _last_absolute_x,
			pos[1] - _last_absolute_y) / delta
		
		velocity = relative + (
			parent_body.velocity if parent_body
				else Vector2.ZERO)
	
	_last_absolute_x = pos[0]
	_last_absolute_y = pos[1]
	
	update_local()
	_update_collider()


@export var facet_tolerance: float = 0.01      # max deviation from the true circle, world px
@export var collider_depth: float = 20000.0    # how thick the ground slab is
@export var origin_reach: float = 8192.0       # keep >= your origin-shift distance


var _facet_step: float
var _facet_half: int
var _facets: Array[CollisionShape2D] = []
var _collider_on := false
var _built_k := 0x7fffffff
var _built_x := INF
var _built_y := INF


func _setup_collider() -> void:
	collision_shape.queue_free()               # remove the old circle
	ground.top_level = true
	ground.global_position = Vector2.ZERO

	# sagitta = L^2 / (8R)  ->  L = sqrt(8 * R * tolerance)
	var facet_len := sqrt(8.0 * radius * facet_tolerance)
	var n := clampi(ceili(log(TAU * radius / facet_len) / log(2.0)), 5, 30)
	_facet_step = TAU / pow(2.0, n)
	var real_len := _facet_step * radius
	_facet_half = ceili(origin_reach / real_len) + 3

	for i in range(_facet_half * 2 + 1):
		var cs := CollisionShape2D.new()
		cs.shape = ConvexPolygonShape2D.new()
		cs.disabled = true
		ground.add_child(cs)
		_facets.append(cs)


func update_local() -> void:
	var f := Global.frame_body
	local_x = absolute_position_x - f.absolute_position_x - Global.origin_offset_x
	local_y = absolute_position_y - f.absolute_position_y - Global.origin_offset_y
	global_position = Vector2(local_x, local_y)


func _update_collider() -> void:
	var dist := sqrt(local_x * local_x + local_y * local_y) - radius
	var near := dist < 50000.0

	if near:
		_rebuild_facets()                       # build before enabling
	if near != _collider_on:
		_collider_on = near
		for cs in _facets:
			cs.set_deferred("disabled", not near)


func _rebuild_facets() -> void:
	# angle of the point on the surface closest to the origin
	var theta := atan2(-local_y, -local_x)
	var kc := int(round(theta / _facet_step))
	if kc == _built_k and local_x == _built_x and local_y == _built_y:
		return                                  # nothing moved, keep current shapes
	_built_k = kc
	_built_x = local_x
	_built_y = local_y

	var r_in := maxf(radius - collider_depth, 0.0)

	for i in range(_facets.size()):
		var k := kc - _facet_half + i
		var a0 := k * _facet_step
		var a1 := (k + 1) * _facet_step
		var c0 := cos(a0)
		var s0 := sin(a0)
		var c1 := cos(a1)
		var s1 := sin(a1)

		# all arithmetic in doubles; Vector2() casts to float32 only at the end
		var o0 := Vector2(local_x + radius * c0, local_y + radius * s0)
		var o1 := Vector2(local_x + radius * c1, local_y + radius * s1)
		var pts: PackedVector2Array
		if r_in > 0.0:
			var i0 := Vector2(local_x + r_in * c0, local_y + r_in * s0)
			var i1 := Vector2(local_x + r_in * c1, local_y + r_in * s1)
			pts = PackedVector2Array([o0, o1, i1, i0])
		else:
			pts = PackedVector2Array([o0, o1, Vector2(local_x, local_y)])

		(_facets[i].shape as ConvexPolygonShape2D).points = pts
