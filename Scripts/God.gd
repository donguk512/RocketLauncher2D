extends Node2D
class_name Universe

const CELESTIAL_BODY = preload("res://Scenes/CelestialBody.tscn")
const PLANETS_DATA_PATH = "res://Data/Planets.json"

# Planet data: 2026-10-11 00:00:00.0000 TDB


func _ready() -> void:
	var data = JsonIO.load_from_path(PLANETS_DATA_PATH)
	
	for planet_name in data:
		var planet_data = data[planet_name]
		var planet: CelestialBody = CELESTIAL_BODY.instantiate()
		
		planet.name = planet_name
		planet.mass = planet_data.mass
		planet.radius = planet_data.radius * Constants.GRID_SIZE_BIG * Global.world_scale
		
		if planet_data.parent_body != "Origin":
			planet.mean_anomaly_epoch = planet_data.mean_anomaly_at_epoch * PI / 180.0
			planet.eccentricity = planet_data.eccentricity
			planet.semi_major_axis = planet_data.semi_major_axis * Constants.GRID_SIZE_BIG * Global.world_scale
			planet.arg_of_periapsis = planet_data.argument_of_periapsis
			planet.debug_color = planet_data.color
		
		add_child(planet)
		Global.bodies[planet_name] = planet
		
	Global.frame_body = Global.bodies.Earth
	
	for planet_name in data:
		if planet_name == "Sun":
			continue
		
		var planet_data = data[planet_name]
		
		Global.bodies[planet_name].parent_body = Global.bodies[planet_data.parent_body]
		Global.bodies[planet_name].init()
	
func _physics_process(delta: float) -> void:
	Global.time += delta * Global.time_scale
