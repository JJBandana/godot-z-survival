extends Area3D
class_name UpgradeItem

@export var upgrade_data: BaseTurretStrategy
@export var rotate_speed := 60.0 # grados por segundo, para que gire lindo

func _process(delta: float) -> void:
	rotation.y += deg_to_rad(rotate_speed) * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if upgrade_data:
			GameManager.upgrade_collected.emit(upgrade_data)
			queue_free()
