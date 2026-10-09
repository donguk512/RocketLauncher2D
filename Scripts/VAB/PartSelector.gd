class_name PartSelector
extends Node2D

@export var selected_parts: Array[PartBase] = []
@export var box_rect: Rect2
@export var box_fill_color: Color = Color("#FFFFFF80")
@export var box_outline_color: Color = Color("#FFFFFFFF")

func select(part: PartBase) -> void:
	selected_parts.append(part)
	
func deselect(part: PartBase) -> void:
	pass
	
func toggle(part: PartBase) -> void:
	pass
	
func clear() -> void:
	pass

func select_in_rect(rect: Rect2, parts: Array[PartBase]):
	pass

func _draw() -> void:
	draw_rect(box_rect, box_fill_color, true)
	draw_rect(box_rect, box_outline_color, false, 2.0)
