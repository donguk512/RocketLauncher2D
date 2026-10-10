extends Node2D

@onready var selector: PartSelector = $Parts
@onready var catalog: Panel = $"../UI/CatalogPanel"

enum State {IDLE, DRAGGING, BOX_SELECTING}
var current_state: State = State.IDLE

var mouse_drag_start = Vector2.ZERO
var part_start_positions: Dictionary = {}
var all_snap_points: Array[Node] = []

func _ready() -> void:
	pass

#
func spawn_part(part_scene: PackedScene) -> void:
	var new_part: PartBase = part_scene.instantiate()
	var mouse_world_pos = get_global_mouse_position()
	
	selector.add_child(new_part)
	new_part.global_position = mouse_world_pos
	
	selector.clear()
	selector.select(new_part)
	
	mouse_drag_start = mouse_world_pos
	_start_drag()
	
func _input(event: InputEvent) -> void:
	if current_state != State.DRAGGING:
		return
	
	if event is InputEventMouseMotion:
		_process_drag(get_global_mouse_position())
			
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.is_pressed():
			_finish_drag()
			current_state = State.IDLE
			
			# get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("vab_rotate_left"):
		_rotate_selection(3)
	elif event.is_action_pressed("vab_rotate_right"):
		_rotate_selection(1)
			
	if current_state == State.DRAGGING:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				_on_lmb_pressed()
			else:
				_on_lmb_released()
				
	elif event is InputEventMouseMotion:
		_on_mouse_move(event)

func _on_lmb_pressed():
	var mouse_world_pos = get_global_mouse_position()
	var clicked_part = _get_part_at_pos(mouse_world_pos)
	var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
	
	mouse_drag_start = mouse_world_pos
		
	if clicked_part:
		if shift_pressed:
			selector.toggle(clicked_part)
		elif clicked_part not in selector.selected_parts:
			selector.clear()
			selector.select(clicked_part)
			
		_start_drag()
	else:
		selector.clear()
		current_state = State.BOX_SELECTING

func _on_lmb_released() -> void:
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
			selector.update_box(mouse_drag_start, mouse_world_pos)

func _start_drag():
	current_state = State.DRAGGING
	part_start_positions.clear()
	all_snap_points = get_tree().get_nodes_in_group("snap_point")
	
	for part in selector.selected_parts:
		part_start_positions[part] = part.global_position
		
		for socket in part.get_snap_points():
			if not socket.connected_point:
				continue
			
			if not socket.connected_point.part in selector.selected_parts:
				socket.unlink()

func _process_drag(mouse_world_pos: Vector2) -> void:
	var mouse_delta = mouse_world_pos - mouse_drag_start
	
	for part in selector.selected_parts:
		part.global_position = part_start_positions[part] + mouse_delta
		
	var snap_offset = SnapSolver.calc_group_snap_offset(
		selector.selected_parts,
		all_snap_points
	)
	
	for part in selector.selected_parts:
		part.global_position += snap_offset
		part.global_position = part.global_position.snapped(
			Vector2.ONE * Constants.GRID_SIZE
		)
			
func _finish_drag() -> void:
	if catalog.is_hovered:	
		for part in selector.selected_parts:
			part.queue_free()
		selector.clear()
	
	SnapSolver.link_sockets(selector.selected_parts, all_snap_points)
	
	#for sock: SnapPoint in all_snap_points:
	#	sock.indicator.visible = false

func _finish_box_select() -> void:
	selector.select_in_box()

var _rotate_functions = [
	func (vec: Vector2) -> Vector2:
		return vec,
		
	func (vec: Vector2) -> Vector2:
		return Vector2(-vec.y, vec.x),
		
	func (vec: Vector2) -> Vector2:
		return Vector2(-vec.y, -vec.x),
		
	func (vec: Vector2) -> Vector2:
		return vec.orthogonal()
]

func _rotate_selection(quarters: int) -> void:
	if selector.selected_parts.is_empty():
		return
	
	for part in selector.selected_parts:
		part_start_positions[part] = part.global_position
		
		for socket in part.get_snap_points():
			if not socket.connected_point:
				continue
			
			if not socket.connected_point.part in selector.selected_parts:
				socket.unlink()
	
	var min_pos = Vector2( INF, INF)
	var max_pos = Vector2(-INF,-INF)
	
	for part in selector.selected_parts:
		var rect = part.collision_shape.shape.get_rect()
		var g_rect = part.global_transform * rect
		
		min_pos.x = min(min_pos.x, g_rect.position.x)
		min_pos.y = min(min_pos.y, g_rect.position.y)
		max_pos.x = max(max_pos.x, g_rect.end.x)
		max_pos.y = max(max_pos.y, g_rect.end.y)
	
	var pivot = (min_pos + max_pos) / 2.0
	pivot = pivot.snapped(Vector2.ONE * Constants.GRID_SIZE)
	
	quarters %= 4
	
	var mouse_delta = get_global_mouse_position() - mouse_drag_start
	
	for part in selector.selected_parts:
		var offset = part.global_position - pivot
		var offset_rotated = _rotate_functions[quarters].call(offset)
		
		part.global_position = pivot + offset_rotated		# revolution
		part.rotation += quarters * PI / 2.0				# rotation
		
		if current_state == State.DRAGGING:
			part_start_positions[part] = part.global_position - mouse_delta
		
	SnapSolver.link_sockets(selector.selected_parts, all_snap_points)

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
