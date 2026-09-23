extends Node2D

const SNAP_DISTANCE: float = 32.0;

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

func apply_snap() -> void:
	var held_markers = held_part.get_snap_points()
	if held_markers.is_empty():
		return
	
	var closest_dist_sqr: float = SNAP_DISTANCE * SNAP_DISTANCE
	var snap_offset: Vector2 = Vector2.ZERO
	var found_snap: bool = false
	
	for h_marker in held_markers:
		for other_part in get_children():
			if other_part == held_part or not (other_part is PartBase):
				continue
			
			for o_marker in other_part.get_snap_points():
				var dist_sqr = h_marker.global_position.distance_squared_to(o_marker.global_position)
				
				if dist_sqr < closest_dist_sqr:
					closest_dist_sqr = dist_sqr
					snap_offset = o_marker.global_position - h_marker.global_position
					found_snap = true
	if found_snap:
		held_part.global_position += snap_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if held_part == null:
		return
	
	var raw_pos = get_global_mouse_position() + drag_offset
	held_part.global_position = raw_pos.snapped(Vector2.ONE * Constants.GRID_SIZE / 4)
	
	apply_snap()
