extends Node2D

@onready var _sprite = $gun
@onready var _gunpoint = $gun/gunpoint
@export var _Type :String
@export var bulletScene : PackedScene
@export var bulletParticle : PackedScene = preload("res://Scenes/particles/bullet_particle.tscn")
@onready var gunWaste : int = 1


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
	if Input.is_action_pressed("Mouse_left") and Global.ammo > 0:
		$FlameParticle.emitting = true
		var bulletPart = bulletParticle.instantiate()
		bulletPart.global_position = _gunpoint.global_position
		get_tree().current_scene.add_child(bulletPart)
		var newbullet = bulletScene.instantiate()
		newbullet.position = _gunpoint.global_position
		var bulletdirection :Vector2= (get_global_mouse_position() - newbullet.global_position).normalized()
		newbullet.global_rotation =bulletdirection.angle()
		Global.ammo -= 1
		get_tree().current_scene.add_child(newbullet)
	else:
		$FlameParticle.emitting = false
