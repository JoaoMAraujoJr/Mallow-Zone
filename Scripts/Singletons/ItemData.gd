extends Node


var weapons := {
	"rifle":{
		"weapon_scene": load("res://Scenes/items/guns/holdable/rifle.tscn"),
		"bullet_scene": load("res://Scenes/items/guns/bullets/rifleBullet.tscn"),
		"texture": load("res://Assets/Textures/items/guns/rifle.png"),
		"max_ammo": 12, # valor maximo de munição
		"waste": 1, # o quanto que gasta de munição
		"ammo_value": 5 #o quanto é recuperado de munição ao pegar ammo
	} ,
	"flamethrower": {
		"weapon_scene": load("res://Scenes/items/guns/holdable/flamethrower.tscn"),
		"bullet_scene": load("res://Scenes/items/guns/bullets/fire_bullet.tscn"),
		"texture": load("res://Assets/Textures/items/guns/flamethrower.png"),
		"max_ammo": 20,
		"waste": 1,
		"ammo_value": 10
	},
	"chainsaw": {
		"weapon_scene": load("res://Scenes/items/guns/holdable/chainsaw.tscn"),
		"texture": load("res://Assets/Textures/items/guns/chainsaw_spr.png"),
		"max_ammo": 99,
		"waste": 1,
		"ammo_value": 99
	},
	"shotgun": {
		"weapon_scene": load("res://Scenes/items/guns/holdable/shotgun.tscn"),
		"texture": load("res://Assets/Textures/items/guns/shotgun_spr.png"),
		"max_ammo": 6,
		"waste": 1,
		"ammo_value": 6
	}
}
var consumables :={
	
}
func get_weapon_names() -> Array:
	return weapons.keys()
