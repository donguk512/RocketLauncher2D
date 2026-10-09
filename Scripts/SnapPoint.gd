class_name SnapPoint
extends Marker2D

@export var connected_point: SnapPoint = null


func unlink() -> void:
	if connected_point:
		connected_point.connected_point = null
	connected_point = null
