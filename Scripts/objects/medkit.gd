extends Node2D
@onready var CaseAnimPlayer : AnimationPlayer = $SubViewportContainer/SubViewport/Node3D/AnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		body.addToHealth(25)
		queue_free()


func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		CaseAnimPlayer.play("OpenCase")
		await CaseAnimPlayer.animation_finished
		CaseAnimPlayer.play("CaseOpened")
	pass # Replace with function body.


func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is Player:
		CaseAnimPlayer.play_backwards("OpenCase")
		await CaseAnimPlayer.animation_finished
		CaseAnimPlayer.play("CaseClosed")
	pass # Replace with function body.
