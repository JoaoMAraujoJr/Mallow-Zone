extends Interactable

@export var warpBiome : String
var warpScene : PackedScene
var warpDisplayArt : Texture2D

@onready var SpriteDisplayArt:Sprite2D = $Warp/LevelMask/LevelSpriteDisplay
@onready var WarpDestinationLabel : Label = $Warp/WarpName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	interactionArea = $Area2D
	if warpBiome == null or warpBiome == "":
		warpBiome = BiomeManager.lastCurrBiome
	if (warpBiome != null) and (warpBiome in BiomeManager.BiomeList):
		SpriteDisplayArt.texture = BiomeManager.BiomeList[warpBiome]["WarpArt"]
		WarpDestinationLabel.text = BiomeManager.BiomeList[warpBiome]["name"]
		warpScene = BiomeManager.BiomeList[warpBiome]["BiomeScene"]
	else:
		queue_free()
	pass # Replace with function body.

func Interact():
	super.Interact()
	BiomeManager.lastCurrBiome = BiomeManager.currentBiome
	BiomeManager.currentBiome = warpBiome
	LoadManager.LoadScene("res://Scenes/Level.tscn")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		Interact()
	pass # Replace with function body.
