extends Node2D
class_name SurfaceArc

var body: CelestialBody
var color := Color.WHITE
var max_error_px := 0.25    # max deviation from the true circle, in screen pixels

func _ready() -> void:
	top_level = true                 # don't inherit the planet's huge translation
	global_position = Vector2.ZERO

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null or body == null:
		return

	var zoom := cam.zoom.x
	var view_half := (get_viewport_rect().size / zoom).length() * 0.5 * 1.1  # world px
	var cam_pos := cam.get_screen_center_position()
	var R := body.radius

	# center -> camera, in doubles
	var vx: float = cam_pos.x - body.local_x
	var vy: float = cam_pos.y - body.local_y
	var D := sqrt(vx * vx + vy * vy)

	if D - R > view_half:            # planet entirely off screen
		return
	if D + view_half < R:            # screen entirely inside the planet
		draw_rect(Rect2(cam_pos - Vector2(view_half, view_half), Vector2(view_half, view_half) * 2.0), color)
		return

	# angular half-width of the arc that falls inside the view circle (law of cosines)
	var theta0 := atan2(vy, vx)
	var c := (R * R + D * D - view_half * view_half) / (2.0 * R * D)
	var phi := PI if c <= -1.0 else acos(minf(c, 1.0))

	# vertex spacing from the allowed error: sagitta = R * dθ² / 8
	var dtheta := sqrt(8.0 * (max_error_px / zoom) / R)
	var n := clampi(ceili(log(TAU / dtheta) / log(2.0)), 6, 24)
	var step := TAU / pow(2.0, n)    # power-of-two grid: finer levels contain coarser ones

	var full := phi >= PI
	var k0 := 0 if full else int(floor((theta0 - phi) / step))
	var k1 := (int(pow(2.0, n)) - 1) if full else int(ceil((theta0 + phi) / step))

	var poly := PackedVector2Array()
	for k in range(k0, k1 + 1):
		var a := k * step
		poly.append(Vector2(body.local_x + R * cos(a), body.local_y + R * sin(a)))

	if not full:
		# close the shape below the surface, deeper than anything on screen
		var r_in := maxf(R - 2.0 * view_half, 0.0)
		if r_in > 0.0:
			for k in range(k1, k0 - 1, -1):
				var a := k * step
				poly.append(Vector2(body.local_x + r_in * cos(a), body.local_y + r_in * sin(a)))
		else:
			poly.append(Vector2(body.local_x, body.local_y))

	draw_colored_polygon(poly, color)
