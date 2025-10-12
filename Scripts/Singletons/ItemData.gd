extends Node


var weapons := {
	"rifle":{
		"weapon_scene": load("res://Scenes/items/guns/holdable/rifle.tscn"),
		"bullet_scene": load("res://Scenes/items/guns/bullets/rifleBullet.tscn"),
		"texture": load("res://Assets/Textures/items/guns/rifle.png"),
		"max_ammo": 12,
		"waste": 1,
		"ammo_value": 5
	} ,
	"flamethrower": {
		"weapon_scene": load("res://Scenes/items/guns/holdable/flamethrower.tscn"),
		"bullet_scene": load("res://Scenes/items/guns/bullets/fire_bullet.tscn"),
		"texture": load("res://Assets/Textures/items/guns/flamethrower.png"),
		"max_ammo": 20,
		"waste": 1,
		"ammo_value": 10
	}
}

func get_weapon_names() -> Array:
	return weapons.keys()
