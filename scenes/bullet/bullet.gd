extends Area3D

var speed: float = 75.0
var lifetime: float = 2.0
var damage: float = 50
var _time_alive: float = 0.0

func _physics_process(delta: float) -> void:
	translate(Vector3.FORWARD * speed * delta)

	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") && body.has_method("apply_damage"):
			
		body.apply_damage(damage)
		queue_free()
