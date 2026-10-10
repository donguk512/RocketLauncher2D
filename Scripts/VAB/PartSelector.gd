class_name PartSelector
extends Node2D

@export var selected_parts: Array[PartBase] = []
@export var box_rect: Rect2
@export var box_fill_color: Color = Color("#FFFFFF40")
@export var box_outline_color: Color = Color("#FFFFFFFF")

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
	for part: PartBase in get_children():
		if box_rect.has_point(part.global_position):
			select(part)
	
	box_selecting = false
	box_rect = Rect2()
	queue_redraw()

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
