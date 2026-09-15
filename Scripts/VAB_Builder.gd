extends Node2D

var held_part: PartBase
var drag_offset = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

func spawn_part(part_scene: PackedScene) -> void:
	var new_part = part_scene.instantiate()
	
	new_part.clicked.connect(on_part_click)
		
	add_child(new_part)
	
	drag_offset = Vector2.ZERO
	held_part = new_part
				

func on_part_click(part: PartBase):
	if held_part == null:
		# Start dragging
		drag_offset = part.global_position - get_global_mouse_position()
		held_part = part
		
	print(part)
	
func _unhandled_input(event: InputEvent) -> void:
	# 부품을 들고 있는 상태에서 화면 빈 곳 어디든 클릭하면 내려놓기
	if held_part != null and event.is_action_pressed("select_part"):
		held_part = null
		get_viewport().set_input_as_handled() # 다른 UI로 클릭이 새어나가지 않게 소비

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if held_part != null:
		held_part.global_position = get_global_mouse_position() + drag_offset
