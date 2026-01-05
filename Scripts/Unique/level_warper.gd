extends Interactable
class_name LevelWarper

@export var warpBiome :Biome

@onready var SpriteDisplayArt:Sprite2D = $Warp/LevelMask/LevelSpriteDisplay
@onready var WarpDestinationLabel : Label = $Warp/WarpName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	interactionArea = $Area2D
	if warpBiome != null:
		SpriteDisplayArt.texture = warpBiome.warpArt
		WarpDestinationLabel.text = warpBiome.name
	else:
		queue_free()
	pass # Replace with function body.

func Interact():
	super.Interact()
	BiomeManager.lastCurrBiome = BiomeManager.currentBiome
	BiomeManager.currentBiome = warpBiome
	print("\n changing biomes from : " + BiomeManager.lastCurrBiome.name + "\n new biome is :" + BiomeManager.currentBiome.name + "\n")

	LoadManager.LoadScene("res://Scenes/Level.tscn")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		Interact()
	pass # Replace with function body.
