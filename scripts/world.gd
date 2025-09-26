extends Node3D

@onready var car: Node3D = $Truck
@onready var spawn_points = $ZombieSpawnPoints.get_children()

func _ready():
	car.charging_started.connect(_on_charging_started)
	car.battery_full.connect(_on_charging_finished)
	car.destroyed.connect(_on_car_destroyed)

	# Escuchar señales de oleadas
	GameManager.wave_started.connect(_on_wave_started)
	GameManager.wave_cleared.connect(_on_wave_cleared)

func _on_charging_started():
	GameManager.start_game(spawn_points) # ahora sí empieza el juego
	print("⚡ El car comenzó a cargarse. Zombies detectaron electricidad...")

func _on_charging_finished():
	print("✅ El car terminó de cargarse. ¡Victoria!")

func _on_car_destroyed():
	print("❌ El car fue destruido. Game Over.")

func _on_wave_started(wave_number: int):
	print("Oleada ", wave_number, " comenzó")

func _on_wave_cleared(wave_number: int):
	print("Oleada ", wave_number, " terminada")
