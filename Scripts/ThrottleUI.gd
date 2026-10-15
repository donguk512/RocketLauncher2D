extends MarginContainer
class_name ThrottleContainer

@onready var progress_bar: ProgressBar = $ProgressBar

func update(throttle_ratio: float):
	progress_bar.value = throttle_ratio
