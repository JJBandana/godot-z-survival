class_name GobotZombie extends CharacterBody3D

signal died

@export_group("Stats")
@export var stats: ZombieStats
var knockback_velocity:= Vector3.ZERO
@export var knockback_friction: float = 30.0
@export var _target: Node3D = null
@onready var _skin: Node3D = %GobotSkin

var _attack_range := 2
var _attack_timer := 0.0

func _ready() -> void:
	if stats:
		stats = stats.duplicate()
	_target = get_tree().get_first_node_in_group("vehicle")

func _physics_process(delta: float) -> void:
	if not _target:
		return

	var to_target: Vector3 = _target.global_position - global_position
	to_target.y = 0
	
	var distance := to_target.length()

	if distance > _attack_range:
		# --- Moverse hacia el auto ---
		var direction = to_target / distance # más barato que normalized()

		var y_velocity := velocity.y
		velocity.y = 0
		velocity = velocity.move_toward(direction * stats.move_speed, stats.acceleration * delta)
		velocity.y = y_velocity + stats.gravity * delta

		# Animación correr solo si realmente se mueve
		if velocity.length() > 0.1:
			_skin.run()

		# Rotar suavemente hacia el auto
		var target_angle = Vector3.BACK.signed_angle_to(direction, Vector3.UP)
		rotation.y = lerp_angle(rotation.y, target_angle, 5.0 * delta)

	else:
		# --- Atacar si está en rango ---
		velocity = Vector3.ZERO
		_skin.idle()

		_attack_timer -= delta
		if _attack_timer <= 0.0:
			attack()
			_attack_timer = stats.attack_cooldown
	
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_friction * delta)
	
	move_and_slide()
	

func apply_damage(amount: int):
	_skin.hurt()
	stats.health -= amount
	print("Zombie received ", amount, " damage. Health remaining: ", stats.health)
	
	if stats.health <= 0:
		die()

func apply_knockback(force: Vector3):
	knockback_velocity += force

func die():
	emit_signal("died")
	queue_free()

func attack():
	_skin.jump()
	if _target and _target.has_method("take_damage"):
		_target.take_damage(stats.damage)
