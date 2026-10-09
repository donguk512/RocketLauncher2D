class_name PartSelector
extends Node2D

@export var selected_parts: Array[PartBase] = []
@export var box_rect: Rect2
@export var box_fill_color: Color = Color("#FFFFFF40")
@export var box_outline_color: Color = Color("#FFFFFFFF")

func select(part: PartBase) -> void:
	selected_parts.append(part)
	
func deselect(part: PartBase) -> void:
	selected_parts.erase(part)
	
func toggle(part: PartBase) -> void:
	if part in selected_parts:
		deselect(part)
	else:
		select(part)
	
func clear() -> void:
	selected_parts.clear()

func select_in_box(parts: Array[Node]):
	for part: PartBase in parts:
		if box_rect.has_point(part.global_position):
			select(part)

func _draw() -> void:
	draw_rect(box_rect, box_fill_color, true)
	draw_rect(box_rect, box_outline_color, false, 2.0)
