class_name FuelTank
extends PartBase

@export var fuel_mass = 0.0;
@export var max_fuel_mass = 1.0;

func drain(ratio: float):
	fuel_mass -= fuel_mass * ratio
