extends Area3D

signal turret_picked_up(player)

var player_inside = null
@onready var boxes: Array[Node] = $Boxes.get_children()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = body

func _on_body_exited(body: Node3D) -> void:
	if body == player_inside:
		player_inside = null

func try_pickup_turret():
	if not player_inside or boxes.is_empty():
		return
	emit_signal("turret_picked_up", player_inside)

	var box = boxes.pop_front()
	box.queue_free()
