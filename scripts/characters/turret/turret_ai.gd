class_name Turret
extends Node3D

@onready var bullet_scene = preload("uid://c67se3ja2lq3r")
@onready var _fire_point: Marker3D = $Barrel/FirePoint

# BULLETS STATS
const BASE_BULLET_DAMAGE := 10.0
const BASE_BULLET_SPEED := 50.0
const BASE_BULLET_PIERCING := 10.0
const BASE_BULLET_KNOCKBACK := 10.0

var current_bullet_damage: float
var current_bullet_speed: float
var current_bullet_piercing: float
var current_bullet_knockback: float

# TURRET STATS
const BASE_FIRE_RATE := 1.0
const BASE_ROTATION_SPEED := 4.0
const BASE_RANGE := 20.0

var current_fire_rate: float
var current_rotation_speed: float = 4.0
var current_range: float

@export var upgrades: Array[BaseTurretStrategy] = []

var _target: Node3D = null
var _time_since_last_shot: float = 0.0

func _ready() -> void:
	GameManager.register_turret(self)
	_recalculate_stats()

func _physics_process(delta: float) -> void:
	_update_target()
	if not _target:
		return

	_rotate_towards_target(delta)
	_try_shoot(delta)

# -------------------------------
# Shoting
# -------------------------------
func _shoot() -> void:
	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()
	
	bullet.damage = current_bullet_damage
	bullet.speed = current_bullet_speed
	
	get_tree().root.add_child(bullet)
	
	bullet.global_position = _fire_point.global_position
	bullet.global_rotation = _fire_point.global_rotation
	
# -------------------------------
# Search nearby enemies
# -------------------------------
func _find_closest_enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node3D = null
	var closest_dist = current_range

	for e in enemies:
		if not is_instance_valid(e):
			continue
		var dist = global_position.distance_to(e.global_position)
		if dist < closest_dist:
			closest = e
			closest_dist = dist
	
	return closest

func _update_target():
	if not _target or not is_instance_valid(_target) or _target.is_queued_for_deletion():
		_target = _find_closest_enemy()
	elif global_position.distance_to(_target.global_position) > current_range:
		_target = null

func _rotate_towards_target(delta: float):
	var to_target = _target.global_position - global_position
	to_target.y = 0
	var target_angle = atan2(to_target.x, to_target.z)
	rotation.y = lerp_angle(rotation.y, target_angle, current_rotation_speed * delta)

func _try_shoot(delta: float):
	_time_since_last_shot += delta
	if _time_since_last_shot >= 1.0 / current_fire_rate:
		_shoot()
		_time_since_last_shot = 0.0

func add_upgrades(upgrade: BaseTurretStrategy):
	upgrades.append(upgrade)
	_recalculate_stats()

func _recalculate_stats():
	current_bullet_damage = BASE_BULLET_DAMAGE
	current_bullet_speed = BASE_BULLET_SPEED
	current_bullet_piercing = BASE_BULLET_PIERCING
	current_bullet_knockback = BASE_BULLET_KNOCKBACK
	
	current_fire_rate = BASE_FIRE_RATE
	current_rotation_speed = BASE_ROTATION_SPEED
	current_range = BASE_RANGE
	
	for upgrade in upgrades:
		upgrade.apply_upgrade(self)
