extends Node2D
class_name PlayerSkinManager


@onready var head := $skin/head_sprites/head
@onready var eyes := $skin/head_sprites/eyes

@onready var torso := $skin/torso_and_legs/torso
@onready var leg_l := $skin/torso_and_legs/legs/left_leg/leg
@onready var leg_r := $skin/torso_and_legs/legs/right_leg/leg

@onready var thisSkin : String = GameManager.currentPlayerSkin
@onready var currentAction := "Idle"
@onready var isBackwards := false
@onready var eyesClosed := false

@onready var animPlayer := $AnimationPlayer
@onready var eyeAnimPlayer := $EyesAnimationPlayer
@onready var footstepsAudioStream := $FootstepsAudioStream
func _ready() -> void:
	currentAction = "Idle"
	_loadSkin(thisSkin)



func _physics_process(delta: float) -> void:
	_assertFacing()
	_assertAction()
	pass

func _assertFacing():
	match isBackwards:
		false:
			eyes.texture = SkinData.PlayerSkins[thisSkin]["eyesClosed"] 
			if !eyesClosed:
				eyes.texture = SkinData.PlayerSkins[thisSkin]["eyesOpen"] 
			head.texture = SkinData.PlayerSkins[thisSkin]["headFront"]
			torso.texture = SkinData.PlayerSkins[thisSkin]["torsoFront"]
			leg_l.texture = SkinData.PlayerSkins[thisSkin]["legFront"]
			leg_r.texture = SkinData.PlayerSkins[thisSkin]["legFront"]
			eyes.z_index = 0
		true:
			eyesClosed = false
			eyes.texture = SkinData.PlayerSkins[thisSkin]["eyesBack"] 
			head.texture = SkinData.PlayerSkins[thisSkin]["headBack"]
			torso.texture = SkinData.PlayerSkins[thisSkin]["torsoBack"]
			leg_l.texture = SkinData.PlayerSkins[thisSkin]["legBack"]
			leg_r.texture = SkinData.PlayerSkins[thisSkin]["legBack"]
			eyes.z_index = -1

func _assertAction():
	match currentAction:
		"Idle":
			animPlayer.play("Idle")
		"Walking":
			animPlayer.play("Walking")

func _setBackwards(Bool : bool):
	isBackwards = Bool

func _setAction(Action : String):
	currentAction = Action

func _loadSkin(skin:String):
	if skin in SkinData.PlayerSkins:
		thisSkin = skin
		eyes.texture = SkinData.PlayerSkins[thisSkin]["eyesOpen"] 
		head.texture = SkinData.PlayerSkins[thisSkin]["headFront"]
		torso.texture = SkinData.PlayerSkins[thisSkin]["torsoFront"]
		leg_l.texture = SkinData.PlayerSkins[thisSkin]["legFront"]
		leg_r.texture = SkinData.PlayerSkins[thisSkin]["legFront"]
	else:
		thisSkin = "Jim"
		_loadSkin("Jim")
		


func Blink ():
	if isBackwards:
		return
	else:
		eyesClosed=true
		
func OpenEyes():
	eyesClosed= false
	
	
func playFootsteps():
	footstepsAudioStream.pitch_scale = randf_range(0.8, 1.2)
	footstepsAudioStream.play()

func _on_blink_timer_timeout() -> void:
	eyeAnimPlayer.play("Blink")
	$BlinkTimer.start()
	pass # Replace with function body.
