extends Node3D

@export var detection_radius: float = 20.0
@export var fire_rate: float = 2.0        # disparos por segundo
@export var rotation_speed: float = 4.0   # velocidad de giro
@export var bullet_scene: PackedScene     # arrastra aquí tu escena de bala

@onready var _fire_point: Marker3D = $Barrel/FirePoint

var being_carried := false
var carrier = null

var _target: Node3D = null
var _time_since_last_shot: float = 0.0

func _ready() -> void:
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
	if _time_since_last_shot >= 1.0 / fire_rate:
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
	bullet.global_position = _fire_point.global_position
	bullet.global_rotation = _fire_point.global_rotation

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
