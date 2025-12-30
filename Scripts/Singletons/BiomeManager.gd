extends Node

var currentBiome :String = "Grasslands"
var lastCurrBiome :String = ""

var BiomeList := {
	"Grasslands":{
		"name": "The Grasslands",
		"BiomeScene": load("res://Scenes/stages/stage_grass.tscn"),
		"WarpArt": load("res://Assets/Textures/entities/StageWarper/levelart/Yard.png")
	},
	"Chess":{
		"name": "The Chess Zone",
		"BiomeScene": load("res://Scenes/stages/stage_chess.tscn"),
		"WarpArt": load("res://Assets/Textures/entities/StageWarper/levelart/Yard.png")
	},
	"Asphalt":{
		"name":"The Alphalt",
		"BiomeScene":load("res://Scenes/stages/stage_asphalt.tscn"),
		"WarpArt": load("res://Assets/Textures/entities/StageWarper/levelart/Yard.png")
	}
}
