extends Node

var currentBiome :String = "Grasslands"

var BiomeList := {
	"Grasslands":{
		"name": "The Grasslands",
		"BiomeScene": preload("res://Scenes/stages/stage_grass.tscn")
	},
	"Chess":{
		"name": "The Chess Zone",
		"BiomeScene": preload("res://Scenes/stages/stage_chess.tscn")
	},
	"Asphalt":{
		"name":"The Alphalt",
		"BiomeScene":preload("res://Scenes/stages/stage_asphalt.tscn")
	}
}
