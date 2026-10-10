extends Node
class_name BuilderState

@onready var builder: Node2D = %Builder
@onready var selector: PartSelector = %Builder.get_node("Selector")

func enter():
	pass

func input(event: InputEvent):
	pass
	
func unhandled_input(event: InputEvent):
	if event.is_action_pressed("vab_rotate_left"):
		_rotate_selection(3)
		pass
	elif event.is_action_pressed("vab_rotate_right"):
		_rotate_selection(1)
		pass

func on_mouse_button_up():
	pass
	
func on_mouse_button_down():
	pass
	
func on_mouse_move(event: InputEventMouseMotion):
	pass

func _rotate_selection(quarters: int) -> void:
	if selector.selected_parts.is_empty():
		return
	
	selector.start_drag()
	
	VABTransform.rotate_parts(selector.selected_parts, quarters)
	
	if builder.current_state != builder.get_node("States/Drag"):
		selector.finish_drag()
		
		
