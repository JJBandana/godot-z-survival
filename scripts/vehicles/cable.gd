extends Node3D
class_name Cable

@onready var car: Truck = self.get_parent()
const CABLE = preload("uid://cklwqkenhie1w")
@export var energy_sources: EnergySource = null

func _connect(vehicle: Truck, pylon: EnergySource):
	var cable_scene = CABLE.instantiate()
	
	var dir : Vector3 = (pylon.global_position - vehicle.global_position).normalized()
	var mid : Vector3 = (vehicle.global_position + pylon.global_position) /2.0
	
	#Ajustar altura y radio antes
	cable_scene.height = vehicle.global_position.distance_to(pylon.global_position)
	cable_scene.radius = 0.1
	
	# Orientación
	var rot = Basis.looking_at(dir, Vector3.UP)
	rot = rot.rotated(Vector3.RIGHT, PI/2)
	
	# Posición en el medio del cable
	cable_scene.global_transform = Transform3D(rot, mid)
	
	cable_scene.visible = true
	vehicle.add_child(cable_scene)
	
	print("POINT_A: ",vehicle.position)
	print("POINT_A: ",vehicle.global_position)
	print("POINT_B: ",pylon.position)
	print("POINT_B: ",pylon.global_position)
	print("CABLE.GLOBAL_POSITION",cable_scene.global_transform)
	print("CABLE.POSITION",cable_scene.transform)
	print("MID", mid)
