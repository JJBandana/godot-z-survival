extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0
@export var carry_speed := 3.0

var carrying_turret = null
var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0
var turret_scene: PackedScene = preload("res://characters/turret/turret.tscn")

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin : SophiaSkin = %SophiaSkin

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for area in get_tree().get_nodes_in_group("pickup_area"):
		area.turret_picked_up.connect(_on_turret_picked_up)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("interact"):
		if not carrying_turret:
			for area in get_tree().get_nodes_in_group("pickup_area"):
				area.try_pickup_turret()
		else:
			place_turret()

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	
	if is_camera_motion: _camera_input_direction = event.screen_relative * mouse_sensitivity
	
func _process(_delta):
	if carrying_turret:
		var forward = _skin.global_transform.basis.z.normalized()
		var place_position = _skin.global_position + forward * 2.0
		place_position.y = 0  # TODO: Adjust later
		carrying_turret.global_position = place_position

		carrying_turret.look_at(place_position - forward, Vector3.UP)

func _physics_process(delta: float) -> void:
	var speed = 3.0 if carrying_turret else move_speed
	
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("left", "right", "forward", "backwards")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * speed, acceleration * delta)
	velocity.y = y_velocity + _gravity * delta
	
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse
	
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_basis = Basis.looking_at(-_last_movement_direction, Vector3.UP)
	_skin.global_basis = _skin.global_basis.slerp(target_basis, rotation_speed * delta)

	
	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		var ground_speed := velocity.length()
		if ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()

func _on_turret_picked_up(player):
	if player != self:
		return

	carrying_turret = turret_scene.instantiate()
	add_child(carrying_turret)
	carrying_turret.global_position = global_position

func place_turret():
	if not carrying_turret:
		return

	# Guardar su transform global antes de cambiar de padre
	var global_t = carrying_turret.global_transform

	carrying_turret.get_parent().remove_child(carrying_turret)
	get_parent().add_child(carrying_turret)

	# Restaurar la posición global
	carrying_turret.global_transform = global_t

	# Ya estaba colocada enfrente en _process
	carrying_turret = null
