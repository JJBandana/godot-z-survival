extends CanvasLayer

@onready var battery_bar: ProgressBar = $Control/BatteryBar
@onready var health_bar: ProgressBar = $Control/HealthBar
@onready var label: Label = $Control/Label

func _ready():
	GameManager.register_hud(self)
	label.visible = false

func connect_to_vehicle(vehicle_node: Node3D):
	if not vehicle_node.is_connected("health_changed", set_health):
		vehicle_node.health_changed.connect(set_health)
	if not vehicle_node.is_connected("battery_changed", set_battery):
		vehicle_node.battery_changed.connect(set_battery)

func set_health(value: float, max_value: float):
	health_bar.max_value = max_value
	health_bar.value = value

func set_battery(value: float, max_value: float):
	battery_bar.max_value = max_value
	battery_bar.value = value
	
func show_defeat():
	label.text = "¡Derrota! El auto fue destruido."
	label.visible = true

func show_victory():
	label.text = "¡Victoria! El auto está cargado."
	label.visible = true
