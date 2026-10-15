extends Node2D
class_name SpaceWorld

@onready var spacecrafts: Node2D = $Spacecrafts

@export var origin_shift_threshold: float = 8192.0 ** 2

func switch_frame(new_body: CelestialBody):
	var old: CelestialBody = Global.frame_body
	
	Global.origin_offset_x += old.absolute_position_x - new_body.absolute_position_x
	Global.origin_offset_y += old.absolute_position_y - new_body.absolute_position_y
	
	for ship in spacecrafts.get_children():
		if ship is Spacecraft:
			ship.linear_velocity += old.velocity - new_body.velocity
	
	Global.frame_body = new_body
	print("Frame body set to: ", new_body)


func _physics_process(delta: float) -> void:
	if not Global.current_ship:
		return
	
	var shift = Global.current_ship.global_position
	
	if shift.length_squared() > origin_shift_threshold:
		print("<SHIFT START>")
		
		Global.origin_offset_x += shift.x
		Global.origin_offset_y += shift.y
		
		for ship in spacecrafts.get_children():
			if ship is Spacecraft:
				ship.global_position -= shift
		#		ship.absolute_position_x = ship.global_position.x + Global.origin_offset_x
		#		ship.absolute_position_y = ship.global_position.y + Global.origin_offset_y
		
		#for planet_name in Global.bodies:
		#	var planet: CelestialBody = Global.bodies[planet_name]
		#	planet.global_position.x = planet.absolute_position_x - Global.origin_offset_x
		#	planet.global_position.y = planet.absolute_position_y - Global.origin_offset_y
		
		
		print("<SHIFT FINISH>")
