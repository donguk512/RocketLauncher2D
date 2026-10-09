extends Panel

@export var available_parts: Array[PackedScene]
@export var is_hovered: bool = false

@onready var part_grid: GridContainer = %PartGrid

const PART_BUTTON = preload("res://Scenes/Parts/PartButton.tscn")


signal part_selected(PackedScene)



func _ready() -> void:
	# Generate part buttons on catalog
	for part in available_parts:
		var btn = PART_BUTTON.instantiate()
		btn.setup(part)
		
		btn.pressed.connect(func():
			part_selected.emit(part)
		)
		part_grid.add_child(btn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	is_hovered = true

func _on_mouse_exited() -> void:
	is_hovered = false
