extends Node

var PlataforScene :PackedScene = preload("res://Scenes/stages/Plataform.tscn")
var currentBiome :Biome 
var lastCurrBiome :Biome

var config :BiomeManagerConfig= load("res://Scripts/Resources/Data/BiomeManagerData.tres")
var biomeList := {}

func _ready() -> void:
	currentBiome = load("res://Scripts/Resources/Biomes/GrassLands.tres")
	lastCurrBiome = currentBiome

	for biome in config.biomeList:
		biomeList[biome.biome_id] = biome
