extends Node

# Referencias a los nodos importantes
var car : Node = null
var hud : Node = null

var _wave_number := 0
var _zombies_to_spawn := 0
var _zombies_alive := 0
var _spawn_points: Array = []

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)

var zombie_scene: PackedScene = preload("res://characters/enemies/zombie_gobot/gobot_z.tscn")
var stats: ZombieStats = preload("res://resources/ZombieStats.tres")

@export var spawn_interval := 1.0 # segundos entre cada spawn
@export var time_between_waves := 5.0 # descanso entre oleadas

func _ready():
	print("GameManager listo.")

# Método para registrar el car
func register_car(car_node: Node):
	car = car_node
	
	car.battery_full.connect(_on_charging_finished)
	car.destroyed.connect(_on_car_destroyed)
	car.charging_started.connect(_on_charging_started)
	# Conectar HUD si ya existe
	if hud:
		hud.connect_to_car(car)

# Método para registrar el HUD
func register_hud(hud_node: Node):
	hud = hud_node
	# Conectar Auto si ya existe
	if car:
		hud.connect_to_car(car)

func _on_charging_finished():
	pass

func _on_charging_started():
	pass

func _on_car_destroyed():
	pass

func start_game(spawn_points: Array):
	_spawn_points = spawn_points
	_wave_number = 0
	_next_wave()

func _next_wave():
	_wave_number += 1
	emit_signal("wave_started", _wave_number)

	# Aumentar dificultad progresivamente
	_zombies_to_spawn = 3 + _wave_number * 2
	_zombies_alive = _zombies_to_spawn

	# Empezar a spawnear zombies poco a poco
	_spawn_wave()

func _spawn_wave():
	if _zombies_to_spawn <= 0:
		return

	# Elegir spawn aleatorio
	var spawn_point = _spawn_points.pick_random()
	var zombie = zombie_scene.instantiate()
	zombie.stats = stats
	spawn_point.add_child(zombie)

	_zombies_to_spawn -= 1

	# Seguir spawneando hasta terminar
	if _zombies_to_spawn > 0:
		get_tree().create_timer(spawn_interval).timeout.connect(_spawn_wave)

func zombie_died():
	_zombies_alive -= 1
	if _zombies_alive <= 0:
		emit_signal("wave_cleared", _wave_number)
		# Esperar antes de empezar la próxima oleada
		get_tree().create_timer(time_between_waves).timeout.connect(_next_wave)
