extends Node3D
class_name CameraController

@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@onready var pivot: Node3D = $CameraPivot

var _camera_input_direction := Vector2.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	# Rotación vertical
	pivot.rotation.x += _camera_input_direction.y * delta
	pivot.rotation.x = clamp(pivot.rotation.x, -PI / 6.0, PI / 3.0)

	# Rotación horizontal
	rotation.y -= _camera_input_direction.x * delta

	# Reset input acumulado
	_camera_input_direction = Vector2.ZERO
