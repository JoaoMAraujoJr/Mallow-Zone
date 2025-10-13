extends Node2D

@onready var _sprite = $gun
@onready var _gunpoint = $gun/gunpoint
@onready var _igniteAudioStream = $IgniteAudioStream
@onready var _FlameAudioStream = $FlameAudioStream
@onready var _flameParticles = $FlameParticle
@export var _Type :String
@export var bulletScene : PackedScene
@export var bulletParticle : PackedScene = preload("res://Scenes/particles/bullet_particle.tscn")
@onready var gunWaste : int = 1
@onready var canShoot := true
@onready var canFlameSoundLoop := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _Type != null :
		if _Type in ItemData.weapons:
			var this_weapon = ItemData.weapons[_Type]
			bulletScene = this_weapon["bullet_scene"]
			gunWaste = this_weapon["waste"]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var gunDir = (get_global_mouse_position() - global_position).normalized()
	rotation = gunDir.angle()
	shootLogic()
	
	pass

func _getSprite() -> Sprite2D:
	return _sprite

func _getGunPoint() -> Marker2D:
	return _gunpoint


func shootLogic() -> void:

	if Input.is_action_just_pressed("Mouse_left")and Global.ammo > 0:
		_igniteAudioStream.pitch_scale = randf_range(0.8,1.3)
		_igniteAudioStream.play()
		_FlameAudioStream.play()
		canFlameSoundLoop = true
	if Input.is_action_pressed("Mouse_left") and Global.ammo > 0:
		_flameParticles.emitting = true
		var bulletPart = bulletParticle.instantiate()
		bulletPart.global_position = _gunpoint.global_position
		get_tree().current_scene.add_child(bulletPart)
		if canShoot:
			canShoot = false
			var newbullet = bulletScene.instantiate()
			newbullet.position = _gunpoint.global_position
			var bulletdirection :Vector2= (get_global_mouse_position() - newbullet.global_position).normalized()
			newbullet.global_rotation =bulletdirection.angle()
			Global.ammo -= 1
			get_tree().current_scene.add_child(newbullet)
			$Timer.start()
	if Input.is_action_just_released("Mouse_left") or Global.ammo <= 0:
		canFlameSoundLoop = false
		_FlameAudioStream.stop()
		_flameParticles.emitting = false

func _flipGun(is_backwards: bool):
	if is_backwards:
		_sprite.scale.y = -abs(_sprite.scale.y)
	else:
		_sprite.scale.y = abs(_sprite.scale.y)


func _on_timer_timeout() -> void:
	canShoot = true
	pass # Replace with function body.


func _on_flame_audio_stream_finished() -> void:
	if canFlameSoundLoop:
		_FlameAudioStream.pitch_scale = randf_range(0.8,1.3)
		_FlameAudioStream.play()
	else:
		_FlameAudioStream.stop()
	pass # Replace with function body.
