class_name SnapPoint
extends Marker2D

@onready var indicator: Sprite2D = $Indicator

var connected_point: SnapPoint = null
var part: PartBase:
	get: return get_parent().get_parent() as PartBase

func unlink() -> void:
	if connected_point:
		connected_point.connected_point = null
		connected_point.indicator.visible = false
		
	connected_point = null
	indicator.visible = false

func link_to(opponent: SnapPoint) -> void:
	opponent.unlink()
	
	connected_point = opponent
	opponent.connected_point = self
	
	indicator.visible = true
	opponent.indicator.visible = true
