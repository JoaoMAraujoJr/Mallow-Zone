extends Interactable
class_name LevelWarper

@export var warpPlace :Place

@onready var SpriteDisplayArt:Sprite2D = $Warp/LevelMask/LevelSpriteDisplay
@onready var WarpDestinationLabel : Label = $Warp/WarpName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	interactionArea = $Area2D
	if warpPlace != null:
		if warpPlace is Biome:
			SpriteDisplayArt.texture = warpPlace.warpArt
		WarpDestinationLabel.text = warpPlace.display_name
	else:
		queue_free()
	pass # Replace with function body.

func Interact():
	super.Interact()
	if warpPlace.level_path:
		LevelManager.last_cur_place = LevelManager.cur_place
		LevelManager.cur_place = warpPlace
		print("\n changing biomes from : " + LevelManager.last_cur_place.display_name + "\n new biome is :" + LevelManager.cur_place.display_name + "\n")
		LoadManager.LoadScene(warpPlace.level_path)
	else:
		print("level not found")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		Interact()
	pass # Replace with function body.
