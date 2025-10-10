extends StaticBody2D

@export var particleScene : PackedScene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Car"):
		var particle = particleScene.instantiate()
		particle.global_position = global_position
		get_tree().current_scene.add_child(particle)
		queue_free()
	pass # Replace with function body.
