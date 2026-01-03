extends Node

var PlataforScene :PackedScene = preload("res://Scenes/stages/Plataform.tscn")
var currentBiome :Biome = preload("res://Scripts/Resources/Biomes/GrassLands.tres")
var lastCurrBiome :Biome = currentBiome
