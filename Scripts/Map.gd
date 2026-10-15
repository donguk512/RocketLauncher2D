extends Node2D

@onready var universe: Universe = %Universe
@onready var ship_icon: Sprite2D = $ShipIcon
@onready var spacecrafts: Node2D = $"../../World/Spacecrafts"

@export var min_zoom: float = 1_000.0
@export var max_zoom: float = 1_000_000_000_000.0

var zoom = 100_000.0
var is_dragging = false

var map_cam_x: float = 0.0
var map_cam_y: float = 0.0

var planet_orbit_points: Dictionary = {}
var planet_orbit_lines: Dictionary = {}

var ship_orbit_line: Line2D

enum lod {LOW, MID, HIGH}


func _calculate_orbit(planet: CelestialBody, iteration: int) -> PackedVector2Array:
	var points = PackedVector2Array()
	
	for i in range(iteration):
		var pos = OrbitMath.calculate_pos(
			i / float(iteration) * TAU,
			planet.eccentricity,
			planet.semi_major_axis,
			planet.arg_of_periapsis
		)
		points.append(Vector2(pos[0], pos[1]) / max_zoom)
	
	points.append(points[0])
	
	return points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2.ZERO
	
	for planet_name: String in Global.bodies:
		var planet: CelestialBody = Global.bodies[planet_name]
		var orbit_line_2d: Line2D = Line2D.new()
		orbit_line_2d.width = 1.0
		orbit_line_2d.default_color = Color(0.25, 0.25, 0.25, 1.0)
		orbit_line_2d.z_index = -1
		
		planet_orbit_points[planet_name] = {
			lod.LOW: _calculate_orbit(planet, 90),
			lod.MID: _calculate_orbit(planet, 360),
			lod.HIGH: _calculate_orbit(planet, 1440) 
		}
		planet_orbit_lines[planet_name] = orbit_line_2d
		
		orbit_line_2d.points = planet_orbit_points[planet_name][lod.LOW]
		add_child(orbit_line_2d)
	
	ship_orbit_line = Line2D.new()
	ship_orbit_line.width = 2.0
	ship_orbit_line.default_color = Color(0.3, 0.7, 1.0, 0.8) # 예쁜 KSP 스타일 하늘색
	ship_orbit_line.z_index = 1
	add_child(ship_orbit_line)
	


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		get_parent().visible = !get_parent().visible
		if get_parent().visible and is_instance_valid(Global.current_ship):
			map_cam_x = Global.current_ship.absolute_position_x
			map_cam_y = Global.current_ship.absolute_position_y
	
	if not get_parent().visible:
		return
		
	if event is InputEventMouseButton:
		# Click
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
			
		elif event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
			var zoom_factor: float = 1.0
			
			if event.is_action_pressed("zoom_in"):
				zoom_factor = clampf(min_zoom / zoom, 0.8, 1.0)
			else:
				zoom_factor = clampf(max_zoom / zoom, 1.0, 1.2)

			var mouse_pos = get_global_mouse_position()
			var screen_center = get_viewport_rect().size / 2.0
			var offset_x = mouse_pos.x - screen_center.x
			var offset_y = mouse_pos.y - screen_center.y
			
			var abs_mouse_x = map_cam_x + offset_x * zoom
			var abs_mouse_y = map_cam_y + offset_y * zoom
			
			zoom *= zoom_factor
			
			map_cam_x = abs_mouse_x - offset_x * zoom
			map_cam_y = abs_mouse_y - offset_y * zoom

	elif event is InputEventMouseMotion:
		# Drag
		if is_dragging:
			map_cam_x -= event.relative.x * zoom
			map_cam_y -= event.relative.y * zoom


func _process(delta: float) -> void:
	if not visible:
		return
	queue_redraw()
	_update_ship_orbit()
		
func _draw() -> void:
	var screen_center = get_viewport_rect().size / 2.0
	
	for planet_name: String in Global.bodies:
		var planet: CelestialBody = Global.bodies[planet_name]
		
		var radius = max(planet.radius / zoom, 3.0)
		var draw_x = screen_center.x + (planet.absolute_position_x - map_cam_x) / zoom
		var draw_y = screen_center.y + (planet.absolute_position_y - map_cam_y) / zoom
		var draw_pos = Vector2(draw_x, draw_y)
		
		draw_circle(draw_pos, radius, planet.debug_color, true)
		draw_string(
			ThemeDB.fallback_font, 
			draw_pos + Vector2(radius, radius),
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
		
		orbit.scale = Vector2.ONE * max_zoom / zoom
		orbit.width = 1.0 / max_zoom * zoom
		orbit.points = planet_orbit_points[planet_name][target_lod]
		
		if planet.parent_body:
			var parent = planet.parent_body
			var p_draw_x = screen_center.x + (parent.absolute_position_x - map_cam_x) / zoom
			var p_draw_y = screen_center.y + (parent.absolute_position_y - map_cam_y) / zoom
			orbit.position = Vector2(p_draw_x, p_draw_y)
		else:
			orbit.position = draw_pos
	
	var ship: Spacecraft = Global.current_ship
	
	if is_instance_valid(ship):
		var s_draw_x = screen_center.x + (ship.absolute_position_x - map_cam_x) / zoom
		var s_draw_y = screen_center.y + (ship.absolute_position_y - map_cam_y) / zoom
		ship_icon.position = Vector2(s_draw_x, s_draw_y)
		ship_icon.rotation = ship.rotation


# Map.gd 맨 아래에 추가
func _update_ship_orbit() -> void:
	var ship = Global.current_ship
	var planet = Global.frame_body
	
	if not is_instance_valid(ship) or not is_instance_valid(planet):
		ship_orbit_line.points = PackedVector2Array()
		return
		
	var pixel_scale = 8.0 # 1m = 8px (물리 계산용 스케일)
	
	# 1. 기준 행성에 대한 상대 위치(r)와 상대 속도(v) 계산 (미터 단위 변환)
	var rel_pos = Vector2(
		ship.absolute_position_x - planet.absolute_position_x,
		ship.absolute_position_y - planet.absolute_position_y
	) / pixel_scale
	
	var rel_vel = (ship.linear_velocity - planet.velocity) / pixel_scale
	
	# 2. 케플러 궤도 6요소 중 핵심 요소 도출 (수학의 마법!)
	var mu = Constants.G * planet.mass
	var r = rel_pos.length()
	
	if r == 0 or mu == 0:
		return
		
	# 각운동량 (h = r x v) : 2D에서는 스칼라 값으로 계산
	var h = rel_pos.x * rel_vel.y - rel_pos.y * rel_vel.x
	
	# 이심률 벡터 (Eccentricity Vector) : 궤도가 얼마나 찌그러졌는지와 방향(근지점)을 알려줌
	# 2D 벡터 외적 공식: v x (0, 0, h) = (v.y * h, -v.x * h)
	var e_vec = Vector2(rel_vel.y * h, -rel_vel.x * h) / mu - (rel_pos / r)
	
	var e = e_vec.length() # 이심률 (0: 원, 0~1: 타원, 1 이상: 쌍곡선/탈출)
	var arg_pe = e_vec.angle() # 근지점 인수 (타원이 기울어진 각도)
	var p = (h * h) / mu # 반통경 (Semi-latus rectum) - 궤도의 크기 비례상수
	
	# 3. 궤도 선 그리기 (진근점 이각 Nu 활용)
	var points = PackedVector2Array()
	var screen_center = get_viewport_rect().size / 2.0
	var steps = 3600 # 타원을 그릴 해상도 (360번 계산해도 프레임 드랍 전혀 없음)
	
	var nu_start = 0.0
	var nu_end = TAU # TAU = 2 * PI (360도)
	
	# 우주선이 탈출 속도(Escape Velocity)에 도달하여 쌍곡선(Hyperbola)을 그릴 때 처리
	if e >= 1.0:
		# 점근선(Asymptote) 각도를 구해서 무한대로 그려지는 것을 방지
		var max_nu = acos(-1.0 / e) - 0.05 
		nu_start = -max_nu
		nu_end = max_nu
		
	var nu_step = (nu_end - nu_start) / steps
	
	for i in range(steps + 1):
		var nu = nu_start + nu_step * i
		
		# ⭐️ 케플러 방정식의 꽃: 각도(nu)만 넣으면 행성 중심으로부터의 거리(radius)가 바로 나옴!
		var radius_m = p / (1.0 + e * cos(nu))
		
		# 땅속(행성 내부)이나 우주 밖 너무 먼 곳은 선 그리기 생략
		if e >= 1.0 and radius_m > 5000000.0:
			continue
			
		# 기준 행성 중심 좌표계(근지점 기준)에서의 X, Y 좌표
		var local_x = radius_m * cos(nu)
		var local_y = radius_m * sin(nu)
		
		# 궤도 기울기(근지점 인수)만큼 회전
		var rotated_x = local_x * cos(arg_pe) - local_y * sin(arg_pe)
		var rotated_y = local_x * sin(arg_pe) + local_y * cos(arg_pe)
		
		# 미터 -> 픽셀로 복구하고 우주 절대 좌표로 변환
		var abs_x = planet.absolute_position_x + rotated_x * pixel_scale
		var abs_y = planet.absolute_position_y + rotated_y * pixel_scale
		
		# 마지막으로 가상 카메라(맵) 화면 좌표로 변환
		var draw_x = screen_center.x + (abs_x - map_cam_x) / zoom
		var draw_y = screen_center.y + (abs_y - map_cam_y) / zoom
		
		points.append(Vector2(draw_x, draw_y))
		
	# 타원형 궤도일 경우 선의 끝을 첫 점과 연결하여 완벽한 고리로 만듦
	if e < 1.0 and points.size() > 0:
		points.append(points[0])
		
	ship_orbit_line.points = points
