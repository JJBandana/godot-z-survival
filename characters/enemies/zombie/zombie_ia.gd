class_name Zombie extends CharacterBody3D

@export_group("Stats")
@export var stats: ZombieStats

var _target: Node3D = null

func apply_damage(amount: int):
	stats.health -= amount
	print("Zombie received ", amount, " damage. Health remaining: ", stats.health)
	
	if stats.health <= 0:
		die()

func die():
	print("Zombie died")
	queue_free()

func _ready() -> void:
	# Busca al jugador dentro del grupo "player"
	# Asegúrate de que tu jugador esté en ese grupo (clic derecho → "Node" → "Groups")
	_target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not _target:
		return

	var to_player: Vector3 = _target.global_position - global_position
	to_player.y = 0

	if to_player.length() > stats.detection_radius:
		return

	# Dirección hacia el jugador
	var direction: Vector3 = to_player.normalized()

	# Guardar y aplicar velocidad en Y
	var y_velocity := velocity.y
	velocity.y = 0

	# Moverse hacia el jugador
	velocity = velocity.move_toward(direction * stats.move_speed, stats.acceleration * delta)

	# Gravedad
	velocity.y = y_velocity + stats.gravity * delta

	move_and_slide()

	# Rotar suavemente hacia el jugador
	if direction.length() > 0.1:
		var target_angle = Vector3.BACK.signed_angle_to(direction, Vector3.UP)
		rotation.y = lerp_angle(rotation.y, target_angle, 5.0 * delta)
