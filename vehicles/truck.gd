extends Node3D

@export var max_health := 200.0
@export var max_battery := 100.0
@export var charge_speed := 2.0 # % por segundo

var health : float
var battery : float
var is_charging := false

signal health_changed(value, max_value)
signal battery_changed(value, max_value)
signal destroyed
signal battery_full
signal charging_started

func _ready():
	GameManager.register_car(self)
	health = max_health
	battery = 0.0
	emit_signal("health_changed", health, max_health)
	emit_signal("battery_changed", battery, max_battery)

func _process(delta):
	if health > 0 and battery < max_battery and is_charging:
		battery += charge_speed * delta
		if battery >= max_battery:
			battery = max_battery
			stop_charging()
		emit_signal("battery_changed", battery, max_battery)

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


func _on_hood_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Player entered")
		start_charging()
