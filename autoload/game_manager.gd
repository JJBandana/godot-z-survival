extends Node

signal upgrade_collected(upgrade_resource: Resource)

# Referencias a los nodos importantes
var vehicle : Node = null
var hud : Node = null
var wave_manager : Node = null
var placed_turrets : Array = []

func _ready():
	upgrade_collected.connect(_on_upgrade_collected)
	
func _on_upgrade_collected(upgrade_resource: Resource):
	if not upgrade_resource:
		return
		
	print("GM: Processing global upgrade: ", upgrade_resource)
	# Aplica la mejora a TODAS las torretas
	for turret_instance in placed_turrets:
		turret_instance.add_upgrades(upgrade_resource)

func register_turret(turret_node):
	placed_turrets.append(turret_node)
	print("GM: New turret registered. Total: ", placed_turrets.size())

func apply_upgrade_to_turret(turret_instance, upgrade_resource):
		turret_instance.upgrades.append(upgrade_resource)
		turret_instance._recalculate_stats()
		
		print("Turret upgraded.")

func register_wave_manager(manager):
	wave_manager = manager

func register_vehicle(vehicle_node: Node):
	vehicle = vehicle_node
	if not vehicle.is_connected("charging_started", _on_charging_started):
		vehicle.charging_started.connect(_on_charging_started)
	if not vehicle.is_connected("battery_full", _on_charging_finished):
		vehicle.battery_full.connect(_on_charging_finished)
	if not vehicle.is_connected("destroyed", _on_vehicle_destroyed):
		vehicle.destroyed.connect(_on_vehicle_destroyed)
	
	if hud:
		hud.connect_to_vehicle(vehicle)

# Método para registrar el HUD
func register_hud(hud_node: Node):
	hud = hud_node
	# Conectar Auto si ya existe
	if vehicle:
		hud.connect_to_vehicle(vehicle)

func _on_charging_started():
	if wave_manager:
		wave_manager.start()

func _on_charging_finished():
	if wave_manager:
		wave_manager.stop()

func _on_vehicle_destroyed():
	if wave_manager:
		wave_manager.stop()
