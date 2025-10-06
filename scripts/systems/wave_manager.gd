extends Node
class_name WaveManager

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)

@onready var zombie_scene: PackedScene = preload("uid://bpgb1b1a6tm4q")
@onready var normal_zombie_resource: ZombieStats = preload("uid://d05eqltsobqku")
@onready var fast_zombie_resource: ZombieStats = preload("uid://bhit8xsssuq7f")
@onready var tank_zombie_resource: ZombieStats = preload("uid://o6uv6byn3m20")
@onready var _spawn_points: Array = self.get_children()

@export var spawn_interval := 1.5
@export var time_between_waves := 5.0

var _wave_number := 0
var _zombies_to_spawn := 0
var _zombies_alive := 0
var _wave_started := false
var _wave_pattern := "mixed"

func start() -> void:
	"""
	Wave System Starts.
	"""
	_wave_started = true
	_wave_number = 0
	_next_wave()

func stop():
	_wave_started = false
	_wave_number = 0

# -----------------------------------------
# 🔹 Generador de waves
# -----------------------------------------

func _next_wave() -> void:
	if not _wave_started:
		return
		
	_wave_number += 1
	emit_signal("wave_started", _wave_number)

	_configure_wave(_wave_number)
	_zombies_alive = _zombies_to_spawn

	_spawn_wave()

func _configure_wave(wave_number: int) -> void:
	"""
	Define el tipo de wave (fast, tank, boss, mixed).
	"""
	if wave_number % 10 == 0:
		# jefe cada 10 waves
		_zombies_to_spawn = 1
		_wave_pattern = "boss"
	elif wave_number % 5 == 0:
		_zombies_to_spawn = 5 + wave_number
		_wave_pattern = "tank"
	elif wave_number % 3 == 0:
		_zombies_to_spawn = 6 + wave_number
		_wave_pattern = "fast"
	else:
		_zombies_to_spawn = 3 + wave_number * 2
		_wave_pattern = "mixed"

# -----------------------------------------
# 🔹 Spawn de zombies
# -----------------------------------------

func _spawn_wave() -> void:
	if not _wave_started or _zombies_to_spawn <= 0:
		return
	
	var spawn_point = _spawn_points.pick_random()
	var zombie = zombie_scene.instantiate()
	zombie.stats = _get_zombie_stats_for_wave()
	spawn_point.add_child(zombie)

	# conectar muerte
	zombie.died.connect(_on_zombie_died)

	_zombies_to_spawn -= 1

	if _zombies_to_spawn > 0:
		# spawn interval dinámico: más rápido con waves altas
		var dynamic_interval = max(0.4, spawn_interval - (_wave_number * 0.05))
		get_tree().create_timer(dynamic_interval).timeout.connect(_spawn_wave)

# -----------------------------------------
# 🔹 Selección de tipo de zombie
# -----------------------------------------

func _get_zombie_stats_for_wave() -> ZombieStats:
	match _wave_pattern:
		"boss":
			return tank_zombie_resource.duplicate() # futuro: boss resource
		"tank":
			return tank_zombie_resource.duplicate()
		"fast":
			return fast_zombie_resource.duplicate()
		"mixed":
			var roll = randi() % 100
			if roll < 60:
				return normal_zombie_resource.duplicate() # 60% normal
			elif roll < 85:
				return fast_zombie_resource.duplicate() # 25% rápido
			else:
				return tank_zombie_resource.duplicate() # 15% tanque
		_:
			return normal_zombie_resource.duplicate()

# -----------------------------------------
# 🔹 Cuando un zombie muere
# -----------------------------------------

func _on_zombie_died() -> void:
	_zombies_alive -= 1
	if _zombies_alive <= 0:
		emit_signal("wave_cleared", _wave_number)
		get_tree().create_timer(time_between_waves).timeout.connect(_next_wave)
