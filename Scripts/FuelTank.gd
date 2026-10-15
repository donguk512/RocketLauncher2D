class_name FuelTank
extends PartBase

@export var fuel_mass: float = 0.0;
@export var max_fuel_mass: float = 1.0;
@export var dry_mass: float = 1000.0;

func _ready() -> void:
	_update_total_mass()
	
func drain(ratio: float):
	fuel_mass -= fuel_mass * ratio
	_update_total_mass()

func _update_total_mass() -> void:
	mass = dry_mass + fuel_mass
