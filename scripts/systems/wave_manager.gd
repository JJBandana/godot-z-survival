extends Node
class_name WaveManager

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)

@onready var zombie_scene: PackedScene = preload("uid://bpgb1b1a6tm4q")
@onready var stats_resource: Resource = preload("uid://d05eqltsobqku")
@onready var _spawn_points: Array = self.get_children()

@export var spawn_interval := 1.5
@export var time_between_waves := 5.0

var _wave_number := 0
var _zombies_to_spawn := 0
var _zombies_alive := 0
var _wave_started := false

func start() -> void:
	"""
	Wave Systems Starts.
	"""
	_wave_started = true
	_wave_number = 0
	_next_wave()


func _next_wave() -> void:
	"""
	New Wave Starts.
	"""
	if not _wave_started:
		return
		
	_wave_number += 1
	emit_signal("wave_started", _wave_number)

	# lógica simple de progresión: +2 zombies cada ola
	_zombies_to_spawn = 3 + _wave_number * 2
	_zombies_alive = _zombies_to_spawn

	_spawn_wave()

func _spawn_wave() -> void:
	"""
	Spawn a zombie and program the next one.
	"""
	if not _wave_started:
		return
	
	if _zombies_to_spawn <= 0:
		return

	var spawn_point = _spawn_points.pick_random()
	var zombie = zombie_scene.instantiate()

	# cada zombie recibe su propia copia de stats
	zombie.stats = stats_resource.duplicate()
	spawn_point.add_child(zombie)

	# conectar al morir
	zombie.died.connect(_on_zombie_died)

	_zombies_to_spawn -= 1

	if _zombies_to_spawn > 0:
		get_tree().create_timer(spawn_interval).timeout.connect(_spawn_wave)


func _on_zombie_died() -> void:
	"""
	Manages when a zombie dies.
	"""
	_zombies_alive -= 1
	if _zombies_alive <= 0:
		emit_signal("wave_cleared", _wave_number)
		get_tree().create_timer(time_between_waves).timeout.connect(_next_wave)

func stop():
	_wave_started = false
	_wave_number = 0
