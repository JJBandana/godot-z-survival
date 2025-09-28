extends BaseTurretStrategy
class_name DamageUpgrade

@export var upgrade_title: String = "Damage Upgrade"
@export var damage_increase := 90.0

func apply_upgrade(turret):
	turret.current_bullet_damage += damage_increase
