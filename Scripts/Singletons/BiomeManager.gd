extends Node

var PlataforScene :PackedScene = preload("res://Scenes/stages/Plataform.tscn")
var currentBiome :Biome = preload("res://Scripts/Resources/Biomes/GrassLands.tres")
var lastCurrBiome :Biome = currentBiome

var config :BiomeManagerConfig= load("res://Scripts/Resources/Data/BiomeManagerData.tres")
var biomeList := {}

func _ready() -> void:
	for biome in config.biomeList:
		biomeList[biome.biome_id] = biome
