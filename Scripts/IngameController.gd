extends Node2D

@onready var throttle_frame: ThrottleContainer = $UI/ThrottleFrame
var current_stage: int = -1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		if event.is_action_pressed("proceed_stage"):
			current_stage += 1
			print("stage ", current_stage, " activated")
			
			var stage_parts = Global.current_ship.stages.get(current_stage)
			if not stage_parts:
				return
			
			for part in stage_parts:
				if part.has_method("enable"):
					part.enable()
				elif part.has_method("separate"):
					part.separate()

func _process(delta: float) -> void:
	if not Global.current_ship:
		return
	
	var throttle: float = Global.current_ship.throttle
	throttle += Input.get_axis("throttle_down", "throttle_up") * delta
	Global.current_ship.throttle = clampf(throttle, 0.0, 1.0)
	throttle_frame.update(Global.current_ship.throttle)
	
	var turn_input = Input.get_axis("torque_left", "torque_right")
	
	if turn_input != 0.0:
		Global.current_ship.angular_damp = 0.0
		Global.current_ship.apply_torque(turn_input * 100000000.0) 
	else:
		Global.current_ship.angular_damp = 5.0
