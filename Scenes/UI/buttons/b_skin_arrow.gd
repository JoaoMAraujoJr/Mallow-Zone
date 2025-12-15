extends Control

signal skin_changed(new_skin: String)

enum dir {
	FOWARD,
	BACKWARD
}
@export var type : dir = dir.FOWARD

@onready var button := $ArrowButton
@onready var floatAnimPlay := $FloatAnimationPlayer
@onready var squishAnimPlay := $SquishAnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == dir.BACKWARD:
		button.flip_h = true
	pass # Replace with function body.



func _on_arrow_button_pressed() -> void:
	squishAnimPlay.play("Squish")
	var skins := SkinData.PlayerSkins.keys()
	if skins.size() == 0:
		return
	
	var currentPlayerSkin = GameManager.currentPlayerSkin
	var currentSkinIndex = skins.find(currentPlayerSkin)
	
	if currentSkinIndex == -1:
		currentSkinIndex =0
		
	
	if type == dir.FOWARD:
		var nextSkinIndex = (currentSkinIndex + 1) % skins.size()
		var newSkin = skins[nextSkinIndex]
		GameManager.currentPlayerSkin = newSkin
		GameManager.emit_signal("skin_changed",newSkin)
	
	if type == dir.BACKWARD:
		var nextSkinIndex = (currentSkinIndex - 1) % skins.size()
		var newSkin = skins[nextSkinIndex]
		GameManager.currentPlayerSkin = newSkin
		GameManager.emit_signal("skin_changed",newSkin)
	
	
	
	pass # Replace with function body.
