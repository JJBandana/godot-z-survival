extends Node3D
# Simple helper para mostrar el marcador y (opcional) la trayectoria
@export var sample_points := 16
@onready var mesh = $MeshInstance3D

func show_at(world_pos: Vector3):
	global_position = world_pos
	visible = true
