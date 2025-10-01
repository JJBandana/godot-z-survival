extends Node3D
class_name Truck

@onready var cables: Cable = $Cables


@export var max_health := 200.0
@export var max_battery := 100.0
@export var battery_charge : float = 0.0 :
	set(new_value):
		battery_charge = new_value
		battery_changed.emit(new_value, max_battery)

@export var _connected_source = null

var health : float
var is_charging := false

signal health_changed(value, max_value)
signal battery_changed(value, max_value)
signal destroyed
signal battery_full
signal charging_started

func _ready():
	GameManager.register_vehicle(self)
	health = max_health
	emit_signal("health_changed", health, max_health)
	emit_signal("battery_changed", battery_charge, max_battery)

func _process(delta):
	if _connected_source:
		var energy = _connected_source.provide_energy(delta)
		
		battery_charge = clampf(battery_charge + energy, 0, max_battery)

func connect_to_energy_source(source: EnergySource) -> void:
	if _connected_source:
		disconnect_from_energy_source()
	_connected_source = source
	cables._connect(self, source)

func disconnect_from_energy_source() -> void:
	_connected_source = null

func take_damage(amount: float):
	if health <= 0:
		return
	health -= amount
	if health <= 0:
		health = 0
		emit_signal("destroyed")
	emit_signal("health_changed", health, max_health)
	
func start_charging():
	if is_charging:
		return
	is_charging = true
	emit_signal("charging_started")

func stop_charging():
	if not is_charging:
		return
	is_charging = false
	emit_signal("battery_full")

func _start_turret_deploy():
	$PickUpArea.enter_deploy_mode()
