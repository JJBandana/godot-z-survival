extends Node3D

@onready var marker: Node3D = $TargetMaker
@onready var camera: Camera3D = $"../CarCamera"
@onready var crate_scene := preload("uid://e1omsfl5niia")
@export var move_speed: float = 10.0
@export var max_distance: float = 20.0  # distancia máxima desde el auto

var in_deploy_mode := false
var _current_target := Vector3.ZERO

func enter_deploy_mode() -> void:
	in_deploy_mode = true
	# El marker arranca en frente del auto
	_current_target = global_position + transform.basis.z * -5.0
	marker.show_at(_current_target)

func exit_deploy_mode() -> void:
	in_deploy_mode = false
	marker.hide()

func _physics_process(delta: float) -> void:
	if not in_deploy_mode:
		return

	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("ui_up"): # W
		input_dir.z += 1
	if Input.is_action_pressed("ui_down"): # S
		input_dir.z -= 1
	if Input.is_action_pressed("ui_left"): # A
		input_dir.x += 1
	if Input.is_action_pressed("ui_right"): # D
		input_dir.x -= 1

	if input_dir != Vector3.ZERO:
		# Convertimos input a espacio del auto
		input_dir = (transform.basis * input_dir).normalized()
		_current_target += input_dir * move_speed * delta

		# Restringir dentro del rango
		var offset = _current_target - global_position
		if offset.length() > max_distance:
			_current_target = global_position + offset.normalized() * max_distance

		# Mantener el marker en el suelo
		_current_target.y = global_position.y
		marker.global_position = _current_target

	# Confirmar con espacio
	if Input.is_action_just_pressed("ui_accept"):
		_confirm_deploy()

func _confirm_deploy() -> void:
	var crate = crate_scene.instantiate()
	self.get_parent().add_child(crate)
	# punto de salida (por encima del capó)
	var start_pos = global_transform.origin + Vector3.UP * 2.0 + transform.basis.z * -1.5
	crate.start_drop(start_pos, _current_target, 1, 10)
	# ocultar marcador y salir del modo
	# Aquí llamás a la animación de la caja que cae
	exit_deploy_mode()
