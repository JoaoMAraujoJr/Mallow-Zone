extends Node2D
class_name PlayerSkinManager

@onready var back_hair := $skin/back_hair

@onready var hat := $skin/head_sprites/hat
@onready var head := $skin/head_sprites/head
@onready var eyes := $skin/head_sprites/eyes

@onready var torso := $skin/torso_and_legs/torso
@onready var leg_l := $skin/torso_and_legs/legs/left_leg/leg
@onready var leg_r := $skin/torso_and_legs/legs/right_leg/leg

@export var thisSkin : PlayerSkin = GameManager.cur_skin
@onready var currentAction := "Idle"
@onready var isBackwards := false
@onready var eyesClosed := false

@onready var animPlayer := $AnimationPlayer
@onready var eyeAnimPlayer := $EyesAnimationPlayer
@onready var footstepsAudioStream := $FootstepsAudioStream
@onready var skullParticleEmitter : GPUParticles2D = $SkullParticleEmitter
@onready var skullCrashingAudioStream :AudioStreamPlayer2D = $SkullCrashingAudioStream

func _ready() -> void:
	currentAction = "Idle"

	if thisSkin:
		_loadSkin(thisSkin)


	GameManager.connect("skin_changed",Callable(self,"on_Skin_Changed"))



func _physics_process(_delta: float) -> void:
	_assertFacing()
	_assertAction()
	pass

func _assertFacing():
	match isBackwards:
		false:
			eyes.region_rect.position.x = 66
			if !eyesClosed:
				eyes.region_rect.position.x = 1
			hat.region_rect.position.x = 4
			head.region_rect.position.x = 1
			torso.region_rect.position.x = 1
			leg_l.region_rect.position.x = 131
			leg_r.region_rect.position.x = 131
			eyes.z_index = 0
		true:
			eyesClosed = false
			hat.region_rect.position.x = 69
			eyes.region_rect.position.x = 131
			head.region_rect.position.x = 66
			torso.region_rect.position.x = 66
			leg_l.region_rect.position.x = 152
			leg_r.region_rect.position.x = 152
			eyes.z_index = -1

func _assertAction():
	match currentAction:
		"Idle":
			animPlayer.play("Idle")
		"Walking":
			animPlayer.play("Walking")
		"Die":
			animPlayer.play("Die")

func _setBackwards(Bool : bool):
	isBackwards = Bool

func _setAction(Action : String):
	currentAction = Action

func _loadSkin(skin:PlayerSkin):
	if skin:
		thisSkin = skin
		hat.texture = thisSkin.texture
		back_hair.texture = thisSkin.texture
		eyes.texture = thisSkin.texture
		head.texture =  thisSkin.texture
		torso.texture =  thisSkin.texture
		leg_l.texture =  thisSkin.texture
		leg_r.texture =  thisSkin.texture


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

func updateTrailParticle(isActive:bool):
	match isActive:
		true:
			for trailScene in $trailParticles.get_children():
				for trail in trailScene.get_children():
					if trail is GPUParticles2D:
						trail.emitting = true
			pass
		false:
			for trailScene in $trailParticles.get_children():
				for trail in trailScene.get_children():
					if trail is GPUParticles2D:
						trail.emitting = false
			pass

func on_Skin_Changed(new_skin: PlayerSkin) -> void:
	_loadSkin(new_skin)
