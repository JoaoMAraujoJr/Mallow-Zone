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
		"bullet_scene": load("res://Scenes/particles/flame_particle.tscn"),
		"texture": load("res://Assets/Textures/items/guns/rifle.png"),
		"max_ammo": 500,
		"waste": 1,
		"ammo_value": 250
	}
}

func get_weapon_names() -> Array:
	return weapons.keys()
