extends Node3D

@export var detection_radius: float = 20.0
@export var rotation_speed: float = 4.0

@onready var bullet_scene = preload("uid://c67se3ja2lq3r")
@onready var _fire_point: Marker3D = $Barrel/FirePoint

const BASE_DAMAGE = 10.0
const BASE_FIRE_RATE = 1.0
const BASE_BULLET_SPEED = 50.0

@export var damage_multiplier: float = 1.0
@export var fire_rate_multiplier: float = 1.0
@export var bullet_speed_additive: float = 0.0

@export var current_damage: float
@export var current_fire_rate: float
@export var current_bullet_speed: float

@export var passive_upgrades: Array[Resource] = []

var being_carried := false
var carrier = null

var _target: Node3D = null
var _time_since_last_shot: float = 0.0

func _ready() -> void:
	recalculate_stats()
	_target = get_tree().get_first_node_in_group("enemies") # o "zombies" si quieres

func _physics_process(delta: float) -> void:
	# Buscar un objetivo si no tenemos uno válido
	if not _target or not is_instance_valid(_target) or _target.is_queued_for_deletion():
		_target = _find_closest_enemy()
	
	if not _target:
		return

	var to_target = _target.global_position - global_position
	to_target.y = 0
	
	if to_target.length() > detection_radius:
		# Objetivo fuera de rango, resetear
		_target = null
		return  

	# Rotación hacia el objetivo
	var target_angle = atan2(to_target.x, to_target.z)
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

	# Control de disparo
	_time_since_last_shot += delta
	if _time_since_last_shot >= 1.0 / current_fire_rate:
		_shoot()
		_time_since_last_shot = 0.0

# -------------------------------
# Disparo
# -------------------------------
func _shoot() -> void:
	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	bullet.damage = current_damage
	bullet.speed = current_bullet_speed
	
	bullet.global_position = _fire_point.global_position
	bullet.global_rotation = _fire_point.global_rotation
	
	# _apply_item_effects_to_bullet(bullet)
# -------------------------------
# Buscar enemigos cercanos
# -------------------------------
func _find_closest_enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node3D = null
	var closest_dist = detection_radius

	for e in enemies:
		if not is_instance_valid(e):
			continue
		var dist = global_position.distance_to(e.global_position)
		if dist < closest_dist:
			closest = e
			closest_dist = dist
	
	return closest

func recalculate_stats():
	damage_multiplier = 1.0
	fire_rate_multiplier = 1.0
	bullet_speed_additive = 0.0
	
	for upgrade in passive_upgrades:
		# Nota: 'upgrade' es la instancia de tu ItemData
		if "damage_mult" in upgrade.stat_modifiers:
			print("multiplied damage")
			damage_multiplier *= (1.0 + upgrade.stat_modifiers["damage_mult"])
		
		if "fire_rate_mult" in upgrade.stat_modifiers:
			print("multiplied fire rate")
			fire_rate_multiplier *= (1.0 + upgrade.stat_modifiers["fire_rate_mult"])
			
		if "bullet_speed_add" in upgrade.stat_modifiers:
			print("multiplied speed")
			bullet_speed_additive += upgrade.stat_modifiers["bullet_speed_add"]
	
	current_damage = BASE_DAMAGE * damage_multiplier
	current_fire_rate = BASE_FIRE_RATE * fire_rate_multiplier
	current_bullet_speed = BASE_BULLET_SPEED + bullet_speed_additive
