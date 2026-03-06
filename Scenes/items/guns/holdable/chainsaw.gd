extends Node2D

@onready var _animatedSprite :AnimatedSprite2D = $gun
@onready var _ShootSound :AudioStreamPlayer2D= $ShootSound
@export var _Type :String
@export var bulletParticle : PackedScene = preload("res://Scenes/particles/bullet_particle.tscn")
@onready var gunWaste : int = 1
@export var damage: int = 3
@onready var _damageArea:Area2D = $gun/damageArea

@onready var hand_R := $gun/RightHand/hand_R
@onready var hand_L := $gun/LeftHand/hand_L

@onready var canWaste := true
@onready var _wastcooldown : Timer = $AmmoWasteCooldown

var cooldown:Timer
var can_hit:bool = true

#TriggerType
enum GunTrigger{
	PRESS,
	HOLD,
	RELEASE
}
@export var TriggerMode : GunTrigger = GunTrigger.PRESS


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_damageArea.monitoring = true
	cooldown = Timer.new()
	cooldown.wait_time=0.2
	cooldown.timeout.connect(func():
		can_hit=true)
	add_child(cooldown)
	loadPlayerSkin()
	if _Type != null :
		if _Type in ItemData.weapons:
			var this_weapon = ItemData.weapons[_Type]
			gunWaste = this_weapon["waste"]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var gunDir = (get_global_mouse_position() - global_position).normalized()
	rotation = gunDir.angle()
	shootLogic()
	
	pass

func shootLogic() -> void:
	if GameManager.can_shoot:
		if Input.is_action_just_pressed("Mouse_left") and GameManager.ammo> 0:
			_ShootSound.pitch_scale =randf_range(0.34 , 0.5)
			_ShootSound.play()
		if Input.is_action_pressed("Mouse_left") and GameManager.ammo > 0:
			_animatedSprite.play("on")
			
			var bodies : = _damageArea.get_overlapping_bodies()
			var hit_count:int = 0
			for body in bodies:
				print("enemy detected by chainsaw")
				if body.has_method("addToHealth") and body is not Player and can_hit:
					hit_count+=1
					print("enemy damaged")
					body.addToHealth(-damage)
			if hit_count >0:
				can_hit = false
				cooldown.start()
			
			var bulletPart = bulletParticle.instantiate()
			bulletPart.global_position = global_position
			get_tree().current_scene.add_child(bulletPart)
			if canWaste and (GameManager.ammo - 1)>=0:
				GameManager.ammo -= 1
				canWaste = false
				_wastcooldown.start()
		else:
			_ShootSound.stop()
			_animatedSprite.play("off")


func _flipGun(is_backwards: bool):
	if is_backwards:
		_animatedSprite.scale.y = -abs(_animatedSprite.scale.y)
	else:
		_animatedSprite.scale.y = abs(_animatedSprite.scale.y)

func loadPlayerSkin():
	var thisSkin = GameManager.currentPlayerSkin
	if thisSkin in SkinData.PlayerSkins:
		hand_L.texture = SkinData.PlayerSkins[thisSkin]["hand"]
		hand_R.texture = SkinData.PlayerSkins[thisSkin]["hand"]


func _on_ammo_waste_cooldown_timeout() -> void:
	canWaste=true
	pass # Replace with function body.
