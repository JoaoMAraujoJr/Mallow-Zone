extends Node2D
class_name Gun

@onready var _sprite = $gun
@export var _ShootSound :AudioStreamPlayer2D
@export var _Type :String
@export var bulletScene : PackedScene
@export var bulletParticle : PackedScene
@onready var gunWaste : int = 1

var canshoot:bool = true

@export var hand_R :Sprite2D
@export var hand_L :Sprite2D
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
			gunWaste = this_weapon["waste"]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var gunDir = (get_global_mouse_position() - global_position).normalized()
	rotation = gunDir.angle()
	shootLogic()
	
	pass

func _getSprite() -> Sprite2D:
	return _sprite


func shootLogic() -> void:
	if GameManager.can_shoot and canshoot:
		match TriggerMode:
			GunTrigger.PRESS:
				if Input.is_action_just_pressed("Mouse_left") and GameManager.ammo > 0:
					if _ShootSound:
						_ShootSound.pitch_scale = randf_range(0.8,1.2)
						_ShootSound.play()
					GameManager.ammo = clamp(GameManager.ammo-gunWaste , 0 ,ItemData.weapons[_Type]["max_ammo"])
					shot()
			GunTrigger.HOLD:
				if Input.is_action_pressed("Mouse_left") and GameManager.ammo > 0:
					if _ShootSound:
						_ShootSound.pitch_scale = randf_range(0.8,1.2)
						_ShootSound.play()
					GameManager.ammo = clamp(GameManager.ammo-gunWaste , 0 ,ItemData.weapons[_Type]["max_ammo"])
					shot()
			GunTrigger.RELEASE:
				if Input.is_action_just_released("Mouse_left") and GameManager.ammo > 0:
					if _ShootSound:
						_ShootSound.pitch_scale = randf_range(0.8,1.2)
						_ShootSound.play()
					GameManager.ammo = clamp(GameManager.ammo-gunWaste , 0 ,ItemData.weapons[_Type]["max_ammo"])
					shot()

	else:
		return

func shot()-> void:
	printerr("shooting method not implemented for "+ _Type)
	pass
	

func _flipGun(is_backwards: bool):
	if is_backwards:
		_sprite.scale.y = -abs(_sprite.scale.y)
	else:
		_sprite.scale.y = abs(_sprite.scale.y)

func loadPlayerSkin():
	var thisSkin = GameManager.cur_skin
	hand_L.texture = thisSkin.texture
	hand_R.texture = thisSkin.texture
