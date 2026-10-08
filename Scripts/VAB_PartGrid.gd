extends GridContainer

@export var available_parts: Array[PackedScene]

const PART_BUTTON = preload("res://Scenes/PartButton.tscn")

signal part_selected(PackedScene)


func _ready() -> void:
	
	# Generate part buttons on catalog
	for part in available_parts:
		var btn = PART_BUTTON.instantiate()
		btn.setup(part)
		
		btn.pressed.connect(func():
			part_selected.emit(part)
		)
		add_child(btn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
