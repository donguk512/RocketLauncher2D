extends Node2D

@onready var selector: PartSelector = $Selector
@onready var workspace: Node2D = $Selector/Workspace
@onready var stages_ui: MarginContainer = $"../UI/Stages"
@onready var staging: BuilderState = $States/Staging

var current_state: BuilderState

func _ready():
	change_state("Idle")
	
	stages_ui.stage_selected.connect(func(index):
		staging.on_stage_selected(index)
		change_state("Staging"))

func change_state(state_name: String):
	current_state = $States.get_node(state_name)
	current_state.enter()

func spawn_part(part_scene: PackedScene) -> void:
	var new_part: PartBase = part_scene.instantiate()
	var mouse_world_pos = get_global_mouse_position()
	
	selector.clear()
	
	new_part.global_position = mouse_world_pos
	workspace.add_child(new_part)
	selector.select(new_part)
	
	change_state("Drag")

func _input(event: InputEvent) -> void:
	current_state.input(event)

func _unhandled_input(event: InputEvent) -> void:
	current_state.unhandled_input(event)
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				current_state.on_mouse_button_down()
			else:
				current_state.on_mouse_button_up()
				
	elif event is InputEventMouseMotion:
		current_state.on_mouse_move(event)
