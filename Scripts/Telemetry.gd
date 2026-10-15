extends MarginContainer
@onready var label: Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var ship := Global.current_ship
	var f_body := Global.frame_body
	
	if not ship or not f_body:
		return
		
	var dx := ship.absolute_position_x - f_body.absolute_position_x
	var dy := ship.absolute_position_y - f_body.absolute_position_y
	
	label.text = (
	"velocity: %.1f m/s
	altitude: %.1f m
	
	%d fps" % [
		ship.linear_velocity.length() / Constants.PIXELS_PER_METER,
		(Vector2(dx, dy).length() - f_body.radius) / Constants.PIXELS_PER_METER,
		1.0 / delta
	])
