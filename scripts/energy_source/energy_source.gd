extends Node3D
class_name EnergySource

@export var generation_rate := 1.0 # energía por segundo
@export var efficiency := 1.0 # 0..1

func provide_energy(delta: float) -> float:
	return generation_rate * efficiency * delta
