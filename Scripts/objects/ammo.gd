extends Node2D


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		var player = area.get_parent()
		if player.has_method("_playReloadSound"):
			player._playReloadSound()
		if GameManager.currentEquipedWeaponType != null and GameManager.currentEquipedWeaponType != "":
			if GameManager.currentEquipedWeaponType in ItemData.weapons:
				if GameManager.ammo + ItemData.weapons[GameManager.currentEquipedWeaponType]["ammo_value"] > GameManager.ammoMax:
					GameManager.ammo = GameManager.ammoMax
				else:
					GameManager.ammo += ItemData.weapons[GameManager.currentEquipedWeaponType]["ammo_value"]
				
		queue_free()
