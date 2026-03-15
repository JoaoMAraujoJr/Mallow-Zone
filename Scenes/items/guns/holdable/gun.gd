extends Node2D

@onready var _sprite = $gun
@onready var _gunpoint = $gun/gunpoint
@onready var _ShootSound = $ShootSound
@export var _Type :String
@export var bulletScene : PackedScene
@export var bulletParticle : PackedScene = preload("res://Scenes/particles/bullet_particle.tscn")
@onready var gunWaste : int = 1

@onready var hand_R := $gun/RightHand/hand_R
@onready var hand_L := $gun/LeftHand/hand_L
#TriggerType
enum GunTrigger{
	PRESS,
	HOLD,
	RELEASE
}
@export var TriggerMode : GunTrigger = GunTrigger.PRESS


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadPlayerSkin()
	if _Type != null :
		if _Type in ItemData.weapons:
			var this_weapon = ItemData.weapons[_Type]
			bulletScene = this_weapon["bullet_scene"]
			gunWaste = this_weapon["waste"]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var gunDir = (get_global_mouse_position() - global_position).normalized()
	rotation = gunDir.angle()
	shootLogic()
	
	pass

func _getSprite() -> Sprite2D:
	return _sprite

func shootLogic() -> void:
	if GameManager.can_shoot:
		match TriggerMode:
			GunTrigger.PRESS:
				if Input.is_action_just_pressed("Mouse_left") and GameManager.ammo > 0:
					_ShootSound.pitch_scale = randf_range(0.8,1.2)
					_ShootSound.play()
					var bulletPart = bulletParticle.instantiate()
					bulletPart.global_position = _gunpoint.global_position
					get_tree().current_scene.add_child(bulletPart)
					var newbullet :Bullet= bulletScene.instantiate()
					newbullet.position = _gunpoint.global_position
					var bulletdirection = (get_global_mouse_position() - newbullet.global_position).normalized()
					newbullet.set_dir(bulletdirection)
					GameManager.ammo -= 1
					get_tree().current_scene.add_child(newbullet)
			GunTrigger.HOLD:
				if Input.is_action_pressed("Mouse_left") and GameManager.ammo > 0:
					_ShootSound.pitch_scale = randf_range(0.8,1.2)
					_ShootSound.play()
					var bulletPart = bulletParticle.instantiate()
					bulletPart.global_position = _gunpoint.global_position
					get_tree().current_scene.add_child(bulletPart)
					var newbullet :Bullet= bulletScene.instantiate()
					newbullet.position = _gunpoint.global_position
					var bulletdirection = (get_global_mouse_position() - newbullet.global_position).normalized()
					newbullet.set_dir(bulletdirection)
					GameManager.ammo -= 1
					get_tree().current_scene.add_child(newbullet)
			GunTrigger.RELEASE:
				if Input.is_action_just_released("Mouse_left") and GameManager.ammo > 0:
					_ShootSound.pitch_scale = randf_range(0.8,1.2)
					_ShootSound.play()
					var bulletPart = bulletParticle.instantiate()
					bulletPart.global_position = _gunpoint.global_position
					get_tree().current_scene.add_child(bulletPart)
					var newbullet :Bullet= bulletScene.instantiate()
					newbullet.position = _gunpoint.global_position
					var bulletdirection = (get_global_mouse_position() - newbullet.global_position).normalized()
					newbullet.set_dir(bulletdirection)
					GameManager.ammo -= 1
					get_tree().current_scene.add_child(newbullet)
	else:
		return

func _flipGun(is_backwards: bool):
	if is_backwards:
		_sprite.scale.y = -abs(_sprite.scale.y)
	else:
		_sprite.scale.y = abs(_sprite.scale.y)

func loadPlayerSkin():
	if GameManager.cur_skin:
		var thisSkin = GameManager.cur_skin
		if thisSkin:
			hand_L.texture = thisSkin.texture
			hand_R.texture = thisSkin.texture
