class_name PartBase

extends Node2D

@export var mass: float = 1.0
@export var icon: Texture2D

@onready var area: Area2D = $Area

signal clicked(part: PartBase)

func get_snap_points() -> Array[Marker2D]:
	var points: Array[Marker2D] = []
	
	for child in $SnapPoints.get_children():
		if child is Marker2D:
			points.append(child)
			
	return points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.input_event.connect(func(_vp, event: InputEvent, _shape_idx):
		if event.is_action_pressed("select_part"):
			clicked.emit(self)
	)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
