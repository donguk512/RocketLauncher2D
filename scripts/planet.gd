@tool #Makes it visible in editor

class_name Planet
extends Node2D

@export var radius: float = 1000.0:
	set(value):
		# Call redraw when updated
		radius = value
		queue_redraw()

@export var planet_color: Color = Color(0.5, 0.67, 1.0)

func _ready() -> void:
	pass # Replace with function body.
	
func _draw() -> void:
	# 점의 개수를 360개~512개로 촘촘하게 늘려 완벽한 구체 생성
	var segments: int = 360 # 1도마다 점 1개 배치
	var points: PackedVector2Array = []
	
	for i in range(segments):
		# TAU = 2 * PI (360도 라디안 상수)
		var angle: float = i * TAU / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	
	# 부드러운 다각형 원 그리기
	draw_colored_polygon(points, planet_color)

func _process(delta: float) -> void:
	pass
