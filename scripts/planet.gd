@tool # 에디터 실시간 동기화 활성화 (Roblox Studio 라이브 스크립팅과 동일)

class_name Planet
extends StaticBody2D

@export var radius: float = 1000.0:
	set(value):
		radius = value
		queue_redraw() # 지표면 드로잉 갱신
		_update_collision_shapes() # 충돌체 및 중력장 크기 자동 동기화

@export var atmosphere_ratio: float = 3.0: # 중력/대기권 영향권 비율 (행성 반지름의 N배)
	set(value):
		atmosphere_ratio = value
		_update_collision_shapes()

@export var planet_color: Color = Color(0.5, 0.67, 1.0)

@onready var collider: CollisionShape2D = $Collider
@onready var gravity_collider: CollisionShape2D = $GravityArea/CollisionShape2D

func _ready() -> void:
	_update_collision_shapes()

func _update_collision_shapes() -> void:
	if collider and collider.shape:
		if not collider.shape.is_local_to_scene():
			collider.shape = collider.shape.duplicate()
		collider.scale = Vector2.ONE
		if collider.shape is CircleShape2D:
			(collider.shape as CircleShape2D).radius = radius
			
	if gravity_collider and gravity_collider.shape:
		if not gravity_collider.shape.is_local_to_scene():
			gravity_collider.shape = gravity_collider.shape.duplicate()
		gravity_collider.scale = Vector2.ONE
		if gravity_collider.shape is CircleShape2D:
			(gravity_collider.shape as CircleShape2D).radius = radius * atmosphere_ratio

func _draw() -> void:
	# 점의 개수를 360개로 촘촘하게 늘려 완벽한 구체 생성
	var segments: int = 360 # 1도마다 점 1개 배치
	var points: PackedVector2Array = []
	
	for i in range(segments):
		# TAU = 2 * PI (360도 라디안 상수)
		var angle: float = i * TAU / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	
	# 부드러운 다각형 원 그리기
	draw_colored_polygon(points, planet_color)
