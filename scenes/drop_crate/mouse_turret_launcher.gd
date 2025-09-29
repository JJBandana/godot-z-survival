extends Area3D

@export var crate_scene:=preload("uid://e1omsfl5niia")
@export var turret_scene:=preload("uid://bn7al7rtwq32n")
@export var max_deploy_range: float = 35.0
@export var default_flight_time: float = 1.2
@export var default_arc_height: float = 8.0

var deploy_mode: bool = false
var _current_target: Vector3 = Vector3.ZERO

# referencias auxiliares (arrastrar en el inspector o buscar en runtime)
@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var marker: Node3D = $TargetMaker

func _ready() -> void:
	if marker:
		marker.visible = false

func _process(_delta: float) -> void:
	if not deploy_mode:
		return
	_update_marker_position()

func enter_deploy_mode() -> void:
	deploy_mode = true
	if marker:
		marker.visible = true

func exit_deploy_mode() -> void:
	deploy_mode = false
	if marker:
		marker.visible = false

func _unhandled_input(event):
	# Confirmar y cancelar (puedes adaptar a tu InputMap)
	if not deploy_mode:
		return
	if event.is_action_pressed("deploy_confirm"):
		_confirm_deploy()
	elif event.is_action_pressed("deploy_cancel"):
		exit_deploy_mode()

func _update_marker_position() -> void:
	if not camera or not marker:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 4000
	
	DebugDraw3D.draw_line(from, to, Color.RED)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [self]

	var intersect: Vector3 = Vector3.ZERO
	var result = space_state.intersect_ray(query)

	if result:
		DebugDraw3D.draw_sphere(result.position, 0.3, Color.GREEN) # Dibujar donde golpea
		intersect = result.position
	else:
		# Si no choca nada, usar simplemente el punto a cierta distancia
		intersect = from + (to - from).normalized() * 30.0

	# Limitar rango desde el auto
	var auto_pos = self.get_parent().global_position
	var direction = intersect - auto_pos
	var max_range := 60
	if direction.length() > max_range:
		intersect = auto_pos + direction.normalized() * max_range

	marker.global_position = intersect
	_current_target = result.position




func _confirm_deploy() -> void:
	# Instanciar la caja y arrancar el drop
	# Empieza desde una posición sobre el auto (ajustala)
	var crate = crate_scene.instantiate()
	self.get_parent().add_child(crate)
	# punto de salida (por encima del capó)
	var start_pos = global_transform.origin + Vector3.UP * 2.0 + transform.basis.z * -1.5
	crate.start_drop(start_pos, _current_target, default_flight_time, default_arc_height)
	# ocultar marcador y salir del modo
	exit_deploy_mode()
