extends Node2D


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		var player = area.get_parent()
		if player.has_method("_playReloadSound"):
			player._playReloadSound()
		Global.ammo += 5
		queue_free()
