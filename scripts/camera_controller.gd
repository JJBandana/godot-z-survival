extends Node3D

const MOUSE_SENSITIVITY = 0.002

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if (event is InputEventMouseMotion):
		rotate_y(event.relative.x * -MOUSE_SENSITIVITY)
		
	if (event.is_action_pressed("ui_cancel")):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
