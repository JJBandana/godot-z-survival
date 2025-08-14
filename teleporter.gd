extends CSGCylinder3D

@export var marker : Marker3D

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("Player detected")
	if marker:
		body.position = marker.global_position
