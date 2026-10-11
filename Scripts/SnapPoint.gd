class_name SnapPoint
extends Marker2D

@onready var indicator: Sprite2D = $Indicator

var linked_point: SnapPoint = null
var part: PartBase:
	get: return get_parent().get_parent() as PartBase

func unlink() -> void:
	if linked_point:
		linked_point.linked_point = null
		linked_point.indicator.visible = false
		
	linked_point = null
	indicator.visible = false

func link_to(opponent: SnapPoint) -> void:
	opponent.unlink()
	
	linked_point = opponent
	opponent.linked_point = self
	
	indicator.visible = true
	opponent.indicator.visible = true
