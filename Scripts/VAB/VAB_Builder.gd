extends Node2D

@onready var vab_ui: CanvasLayer = $"../UI"
@onready var selector: PartSelector = $"../PartSelector"
@onready var catalog_panel: Panel = vab_ui.get_node("CatalogPanel")

enum State {IDLE, DRAGGING, BOX_SELECTING}
var current_state: State = State.IDLE

var mouse_drag_start = Vector2.ZERO
var part_start_positions: Dictionary = {}

func _ready() -> void:
	pass

func spawn_part(part_scene: PackedScene) -> void:
	var new_part = part_scene.instantiate()
	add_child(new_part)
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_on_lmb_pressed(event)
		else:
			_on_lmb_released(event)
			
	elif event is InputEventMouseMotion:
		_on_mouse_move(event)


func _on_lmb_pressed(event: InputEventMouseButton):
	var mouse_world_pos = get_global_mouse_position()
	var clicked_part = _get_part_at_pos(mouse_world_pos)
	var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
	
	mouse_drag_start = mouse_world_pos
		
	if clicked_part:
		print("clicked on part")
		if shift_pressed:
			selector.toggle(clicked_part)
		elif clicked_part not in selector.selected_parts:
			selector.clear()
			selector.select(clicked_part)
			
		_start_dragging(mouse_world_pos)
	else:
		print("clicked on background")
		selector.clear()
		current_state = State.BOX_SELECTING
		

func _on_lmb_released(_event: InputEventMouseButton) -> void:
	match current_state:
		State.DRAGGING:
			_finish_drag()
		State.BOX_SELECTING:
			_finish_box_select()
	
	current_state = State.IDLE
	
func _on_mouse_move(_event: InputEventMouseMotion) -> void:
	var mouse_world_pos = get_global_mouse_position()
	
	match current_state:
		State.DRAGGING:
			_process_drag(mouse_world_pos)
			
		State.BOX_SELECTING:
			selector.box_rect = Rect2(
				mouse_drag_start, 
				mouse_world_pos - mouse_drag_start
			).abs()
			selector.queue_redraw()


func _process_drag(mouse_world_pos: Vector2) -> void:
	var mouse_delta = mouse_world_pos - mouse_drag_start
	
	for part in selector.selected_parts:
		part.global_position = part_start_positions[part] + mouse_delta
		
	var snap_offset = SnapSolver.calc_group_snap_offset(
		selector.selected_parts,
		get_tree().get_nodes_in_group("snap_point")
	)
	
	for part in selector.selected_parts:
		part.global_position += snap_offset
		part.global_position = part.global_position.snapped(
			Vector2.ONE * Constants.GRID_SIZE
		)

func _finish_drag() -> void:
	for part in selector.selected_parts:
		pass

func _finish_box_select() -> void:
	selector.select_in_box(get_children())

func _get_part_at_pos(world_pos: Vector2) -> PartBase:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var hits = space_state.intersect_point(query)
	for hit in hits:
		var collider: CollisionObject2D = hit.collider
		
		if collider is Area2D and collider.get_parent() is PartBase:
			return collider.get_parent() as PartBase
			
	return null
	
func _start_dragging(mouse_pos: Vector2):
	current_state = State.DRAGGING
	part_start_positions.clear()
	
	for part in selector.selected_parts:
		part_start_positions[part] = part.global_position
		
		for socket in part.get_snap_points():
			socket.unlink()


func _process(delta: float) -> void:
	pass
