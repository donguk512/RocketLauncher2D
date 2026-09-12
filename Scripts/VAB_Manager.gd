extends GridContainer

@export var available_parts: Array[PackedScene]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	for part in available_parts:
		# var btn
		var temp = part.instantiate()
		
		#  = temp.icon

		temp.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

