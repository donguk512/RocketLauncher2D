extends GridContainer

@export var available_parts: Array[PackedScene]

const PART_BUTTON = preload("res://Scenes/PartButton.tscn")

signal part_selected(PackedScene)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
