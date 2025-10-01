extends CharacterBody3D

var inside_car:= false

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0
@export var carry_speed := 3.0
@export var interact_distance := 3.0

var carrying_turret = null
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0
var turret_scene: PackedScene = preload("res://scenes/characters/turret/turret.tscn")
var camera_original_transform: Transform3D
var camera_original_length: float

@onready var car : Truck = get_tree().get_first_node_in_group("vehicle")
@onready var _camera: Camera3D = $CameraController/CameraPivot/SpringArm3D/Camera3D
@onready var _camera_pivot: Node3D = $CameraController/CameraPivot
@onready var _skin: SophiaSkin = %SophiaSkin
@onready var world_node: Node3D = get_parent()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("deploy_turret"):
		if inside_car:
			car._start_turret_deploy()

func _process(_delta):		
	if Input.is_action_just_pressed("interact"):
		var energy_source = _find_nearest_panel()
		if energy_source and car:
			car.connect_to_energy_source(energy_source)
		elif not inside_car and car and global_position.distance_to(car.global_position) < 3.0:
			_enter_car()
		elif inside_car:
			_exit_car()

func _physics_process(delta: float) -> void:
	var speed = 3.0 if carrying_turret else move_speed
	
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
	
func _enter_car() -> void:
	inside_car = true
	visible = false
	set_physics_process(false) # desactivar control del player
	
	camera_original_transform = $CameraController.global_transform
	camera_original_length = $CameraController/CameraPivot/SpringArm3D.get_hit_length()
	
	var car_cam_pos = car.global_transform.origin
	$CameraController.global_transform.origin = car_cam_pos

	# Ajustar distancia de la cámara (SpringArm)
	$CameraController/CameraPivot/SpringArm3D.spring_length = 10
	
	
func _exit_car() -> void:
	inside_car = false
	visible = true
	var prev_rot = $CameraController.transform.basis
	global_position = car.global_position + Vector3(2, 0, 0)  # salir al lado
	_camera.current = true
	$CameraController.transform = Transform3D(prev_rot, Vector3.ZERO)
	$CameraController/CameraPivot/SpringArm3D.spring_length = 5.0
	
	set_physics_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _find_nearest_panel() -> EnergySource:
	var generators = get_tree().get_nodes_in_group("energy_sources")
	var closest: EnergySource = null
	var min_dist = interact_distance
	for p in generators:
		var dist = global_position.distance_to(p.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = p
	return closest
