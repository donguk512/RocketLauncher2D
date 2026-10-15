class_name PartSelector
extends Node2D

@onready var workspace: Node2D = %Workspace

@export var selected_parts: Array[PartBase] = []
@export var box_rect: Rect2
@export var box_fill_color: Color = Color("#FFFFFF40")
@export var box_outline_color: Color = Color("#FFFFFFFF")

var part_start_positions: Dictionary = {}
var all_snap_points: Array[Node] = []
var box_selecting = false

func select(part: PartBase) -> void:
	selected_parts.append(part)
	part.highlight()
	
func deselect(part: PartBase) -> void:
	selected_parts.erase(part)
	part.unhighlight()
	
func toggle(part: PartBase) -> void:
	if part in selected_parts:
		deselect(part)
	else:
		select(part)
	
func clear() -> void:
	for part: PartBase in selected_parts:
		part.unhighlight()
		
	selected_parts.clear()

func update_box(mouse_start_pos: Vector2, mouse_pos: Vector2):
	box_rect = Rect2(mouse_start_pos, mouse_pos - mouse_start_pos).abs()
	box_selecting = true
	queue_redraw()

func select_in_box():
	for part: PartBase in workspace.get_children():
		if box_rect.has_point(part.global_position):
			select(part)
	
	box_selecting = false
	box_rect = Rect2()
	queue_redraw()
	
	
func start_drag() -> void:
	part_start_positions.clear()
	all_snap_points = get_tree().get_nodes_in_group("snap_point")
	
	for part in selected_parts:
		part_start_positions[part] = part.global_position
		
		for socket in part.get_snap_points():
			if not socket.linked_point:
				continue
			
			if not socket.linked_point.part in selected_parts:
				socket.unlink()

func drag(offset: Vector2) -> void:
	for part in selected_parts:
		part.global_position = part_start_positions[part] + offset
		
func finish_drag() -> void:
	SnapSolver.link_sockets(selected_parts, all_snap_points)

func snap():
	var snap_offset = SnapSolver.calc_group_snap_offset(
		selected_parts,
		all_snap_points
	)
	
	for part in selected_parts:
		var bound_rect: ReferenceRect = part.get_node("Boundary")
		var bound_offset := part.global_position - bound_rect.global_position
		
		part.global_position += snap_offset
		
		part.global_position = bound_rect.global_position.snapped(
			Vector2.ONE * Constants.GRID_SIZE
		) + bound_offset

func remove():
	for part in selected_parts:
		part.queue_free()
	clear()


func _draw() -> void:
	var zoom = get_viewport().get_camera_2d().zoom.x
	
	if box_selecting:
		draw_rect(box_rect, box_fill_color, true)
		draw_rect(box_rect, box_outline_color, false, 2.0 / zoom)
	
	for part: PartBase in selected_parts:
		part.queue_redraw()

func _ready() -> void:
	var camera = get_viewport().get_camera_2d()
	camera.zoom_changed.connect(func(): queue_redraw())
