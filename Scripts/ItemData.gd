extends Node


var weapons := {
	"rifle": {
		"weapon_scene": preload("res://Scenes/items/guns/holdable/rifle.tscn"),
		"bullet_scene": preload("res://Scenes/items/guns/bullets/rifleBullet.tscn"),
		"texture": preload("res://Assets/Textures/items/guns/rifle.png"),
		"max_ammo": 12
	}	
}

func get_weapon_names() -> Array:
	return weapons.keys()
