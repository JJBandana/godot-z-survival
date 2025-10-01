extends Node3D
class_name DropCrate
# Caja que vuela en parábola y al aterrizar instancia la torreta
@onready var launch: GPUParticles3D = $Particles/Launch
@onready var trail: GPUParticles3D = $Particles/Trail
@onready var deploy: GPUParticles3D = $Particles/Deploy

const TURRET = preload("uid://bn7al7rtwq32n")
@export var total_flight_time: float = 1.2    # segundos
@export var arc_height: float = 8.0           # altura máxima de la parábola
@export var impact_delay: float = 0.15        # tiempo antes de que la torreta empiece a disparar

var _start: Vector3
var _target: Vector3
var _time := 0.0
var _flying := false

func start_drop(start_pos: Vector3, target_pos: Vector3, flight_time: float = -1.0, height: float = -1.0) -> void:
	"""
	Llamar cuando instancies la caja.
	start_pos: punto de salida (por ejemplo, cerca del auto)
	target_pos: punto en el suelo donde quieres que aterrice
	"""
	_start = start_pos
	_target = target_pos
	_time = 0.0
	if flight_time > 0.0:
		total_flight_time = flight_time
	if height > 0.0:
		arc_height = height
	global_position = _start
	_flying = true
	launch.emitting = true
	trail.emitting = true
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not _flying:
		return

	_time += delta
	var t = clampf(_time / total_flight_time, 0.0, 1.0)

	# Interpolación lineal en XY + parábola en Y usando sin(pi * t)
	var pos := _start.lerp(_target, t)
	pos.y += sin(t * PI) * arc_height

	global_position = pos

	# rotación suave para que la caja "gire"
	rotate_z(5.0 * delta)

	if t >= 1.0:
		_flying = false
		_on_landed()

func _on_landed() -> void:
	# Puedes reproducir partículas/sonido aquí
	trail.emitting = false
	deploy.emitting = true
	# Espera un poco (visual) y luego instancia la torreta
	await get_tree().create_timer(impact_delay).timeout

	_spawn_turret()
	
	await get_tree().create_timer(trail.lifetime).timeout
	queue_free()

func _spawn_turret() -> void:
	if TURRET:
		var turret = TURRET.instantiate()
		# Añadir al mundo (raíz de la escena actual)
		get_tree().current_scene.add_child(turret)
		# Ajustar posición final (hacer un raycast a tierra por si hace falta)
		var land_pos = _target
		# raycast hacia abajo para ajustar altura al terreno si hace falta
		var from = _target + Vector3.UP * 5.0
		var to = _target + Vector3.DOWN * 10.0
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var res = get_world_3d().direct_space_state.intersect_ray(query)
		if res:
			land_pos = res.position
		turret.global_position = land_pos
		# Opcional: activa animación de despliegue en la torreta si existe
		if turret.has_method("on_deployed"):
			turret.on_deployed()
