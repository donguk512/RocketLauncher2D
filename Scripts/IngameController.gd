extends Node2D

@onready var throttle_frame: ThrottleContainer = $UI/ThrottleFrame

var current_stage: int = -1
var throttling_up = false
var throttling_down = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		if event.is_action_pressed("proceed_stage"):
			current_stage += 1
			print("stage ", current_stage, " activated")
			
			var stage_parts = Global.current_ship.stages.get(current_stage)
			if not stage_parts:
				return
			
			print(stage_parts)
			
			for part in stage_parts:
				if part is PartEngine:
					part.enable()

		elif event.is_action_pressed("throttle_up") or event.is_action_pressed("throttle_down"):
			if event.is_action_pressed("throttle_up"):
				throttling_up = true
			if event.is_action_pressed("throttle_down"):
				throttling_down = true
	else:
		if event.is_action_released("throttle_up"):
			throttling_up = false
		if event.is_action_released("throttle_down"):
			throttling_down = false
		
			
	
func _process(delta: float) -> void:
	if not Global.current_ship:
		return
	
	var throttle: float = Global.current_ship.throttle
	
	if throttling_up:
		throttle += 50.0 * delta
	if throttling_down:
		throttle -= 50.0 * delta
	
	Global.current_ship.throttle = clampf(throttle, 0.0, 100.0)
	
	throttle_frame.update(Global.current_ship.throttle)
