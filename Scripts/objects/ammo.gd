extends Node2D


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		var player = area.get_parent()
		if player.has_method("_playReloadSound"):
			player._playReloadSound()
		if Global.currentEquipedWeaponType != null and Global.currentEquipedWeaponType != "":
			Global.ammo += ItemData.weapons[Global.currentEquipedWeaponType]["ammo_value"]
		queue_free()
