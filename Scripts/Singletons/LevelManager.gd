extends Node

var PlataforScene :PackedScene = preload("res://Scenes/stages/Plataform.tscn")
var cur_place :Place 
var last_cur_place :Place

var config :BiomeManagerConfig= load("res://Scripts/Resources/Data/BiomeManagerData.tres")
var placeList := {}

func _ready() -> void:
	cur_place = load("res://Scripts/Resources/Biomes/GrassLands.tres")
	last_cur_place = cur_place

	for place in config.biomeList:
		placeList[place.place_id] = place
