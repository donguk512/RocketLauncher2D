extends BuilderState

@onready var stages_ui: MarginContainer = $"../../../UI/Stages"
@onready var workspace: Node2D = %Workspace

var active_stage_index: int = -1


func on_stage_selected(stage_idx: int) -> void:
	active_stage_index = stage_idx
	refresh_stage_visuals()
	
func enter():
	pass

func refresh_stage_visuals() -> void:
	var all_parts = workspace.get_children()
	for child in all_parts:
		if child is PartBase:
			if active_stage_index != -1 and child.stage_index == active_stage_index:
				child.highlight()
			else:
				child.unhighlight()			
	
	stages_ui.refresh_stage_icons(all_parts)

func _stageable(part: PartBase) -> bool:
	return (
		part is PartEngine
	)

func on_mouse_button_down():
	var mouse_world_pos = builder.get_global_mouse_position()
	var clicked_part = PartPicker.get_part_at_pos(
		builder.get_world_2d().direct_space_state,
		mouse_world_pos
	)
	
	print(active_stage_index)
	if active_stage_index == -1:
		builder.change_state("Idle")
		return
	
	print(clicked_part)
	if clicked_part:
		if not _stageable(clicked_part):
			return true
		
		if clicked_part.stage_index == active_stage_index:
			clicked_part.stage_index = -1
		else:
			clicked_part.stage_index = active_stage_index
			
		refresh_stage_visuals()
		

func _rotate_selection(quarters: int) -> void:
	pass
