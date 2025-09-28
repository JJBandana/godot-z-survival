extends TurretUpgrade
class_name DamageUpgrade

@export var bonus_damage := 10

func apply_to_turret(turret: Node) -> void:
	if not turret.has_meta("bonus_damage"):
		turret.set_meta("bonus_damage", 0)
	
	var current = turret.get_meta("bonus_damage")
	turret.set_meta("bonus_damage", current + bonus_damage)
