extends Node2D


@onready var CaseAnimPlayer : AnimationPlayer = $SubViewportContainer/SubViewport/Node3D/AnimationPlayer
@onready var CaseAudStream : AudioStreamPlayer2D = $CaseAudioStream

func _on_player_collision_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.has_method("_playReloadSound"):
			body._playReloadSound()
		if GameManager.currentEquipedWeaponType != null and GameManager.currentEquipedWeaponType != "":
			if GameManager.currentEquipedWeaponType in ItemData.weapons:
				if GameManager.ammo + ItemData.weapons[GameManager.currentEquipedWeaponType]["ammo_value"] > GameManager.ammoMax:
					GameManager.ammo = GameManager.ammoMax
				else:
					GameManager.ammo += ItemData.weapons[GameManager.currentEquipedWeaponType]["ammo_value"]
				
		queue_free()
	pass # Replace with function body.

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		CaseAudStream.pitch_scale = randf_range(0.4,1.2)
		CaseAudStream.play()
		CaseAnimPlayer.play("OpenCase")
		await CaseAnimPlayer.animation_finished
		CaseAnimPlayer.play("CaseOpened")
	pass # Replace with function body.

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is Player:
		CaseAnimPlayer.play_backwards("OpenCase")
		await CaseAnimPlayer.animation_finished
		CaseAudStream.pitch_scale = randf_range(0.4,1.2)
		CaseAudStream.play()
		CaseAnimPlayer.play("CaseClosed")
	pass # Replace with function body.

#signals:

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	$TimerToDeleteSelf.start()
	pass # Replace with function body.ss

func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	$TimerToDeleteSelf.stop()
	pass # Replace with function body.

func _on_timer_to_delete_self_timeout() -> void:
	print("3D propDeleted")
	queue_free()
	pass # Replace with function body.
