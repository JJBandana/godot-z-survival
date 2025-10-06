class_name BaseTurretStrategy
extends Resource

# 📌 Info general
@export var upgrade_title: String = "Unnamed Upgrade"
@export var upgrade_text: String = "No description"
@export_enum("common", "rare", "epic", "legendary") var rarity: String = "common"

# 📌 Aplicación global o individual
@export var is_global: bool = false

# 📌 Stats básicos (si están en 0 o 1, no afectan)
@export var damage: float = 0
@export var fire_rate_multiplier: float = 1.0
@export var bullet_speed: float = 0

# 📌 Modificadores extra
@export var extra_shots: int = 0
@export var max_bounces: int = 0
@export var pierce: int = 0  # -1 = infinito

# 📌 Efectos elementales
@export var burn_damage: float = 0
@export var burn_duration: float = 0
@export var freeze_duration: float = 0
@export var chain_targets: int = 0  # Para electricidad

# 📌 Daño en área
@export var area_damage: float = 0
@export var area_radius: float = 0

# 📌 Control especial
@export var homing: bool = false

# ⚡ Aplica mejoras al recibir upgrade
func apply_upgrade(turret):
	if damage > 0:
		turret.current_bullet_damage += damage

	if fire_rate_multiplier != 1.0:
		turret.current_fire_rate *= fire_rate_multiplier

	if bullet_speed:
		turret.current_bullet_speed += bullet_speed

	if extra_shots > 0:
		turret.current_shots_per_attack += extra_shots

	if max_bounces > 0:
		turret.current_max_bounces += max_bounces

	if pierce != 0:
		if pierce == -1:
			turret.current_pierce = -1
		else:
			turret.current_pierce += pierce

	if burn_damage > 0:
		turret.has_fire_effect = true
		turret.current_burn_damage = burn_damage
		turret.current_burn_duration = burn_duration

	if freeze_duration > 0:
		turret.has_ice_effect = true
		turret.current_freeze_duration = freeze_duration

	if chain_targets > 0:
		turret.has_chain_effect = true
		turret.current_chain_targets = chain_targets

	if area_damage > 0 and area_radius > 0:
		turret.has_explosion = true
		turret.current_area_damage = area_damage
		turret.current_area_radius = area_radius

	if homing:
		turret.has_homing = true
