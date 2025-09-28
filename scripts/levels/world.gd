extends Node3D

@onready var vehicle: Node3D = $Truck
@onready var hud: CanvasLayer = $HUD
@onready var wave_manager: WaveManager = $ZombieSpawnPoints

func _ready():
	GameManager.register_vehicle(vehicle)
	GameManager.register_hud(hud)
	GameManager.register_wave_manager(wave_manager)
	
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_cleared.connect(_on_wave_cleared)

func _on_wave_started(wave_number: int):
	print("Wave ", wave_number, " started")

func _on_wave_cleared(wave_number: int):
	print("Wave ", wave_number, " cleared")
