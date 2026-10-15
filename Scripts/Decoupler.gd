class_name PartDecoupler
extends PartBase

@export var separation_force: float = 200000.0
var has_decoupled: bool = false

func separate() -> void:
	if has_decoupled:
		return
	has_decoupled = true
	
	# 우주선 본체(Spacecraft)에게 나를 기준으로 아래쪽을 잘라내라고 명령
	var ship = get_parent() as Spacecraft
	if ship and ship.has_method("separate_parts_from"):
		ship.separate_parts_from(self, separation_force)
