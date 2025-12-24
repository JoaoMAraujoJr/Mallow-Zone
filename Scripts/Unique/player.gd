# Attach this script to a CharacterBody2D node
extends CharacterEntity
class_name Player

@onready var _iswalking : bool = false
@onready var _isbackwards: bool= false
@onready var _canmove: bool = true

@onready var camera : Camera2D = $Camera2D

@onready var _PlayerArea : Area2D = $PlayerArea2D
@onready var _lifebar : TextureProgressBar= $LifeBar
var _gun : Node2D 
@onready var _gunPivot : Marker2D = $GunPivot
@onready var _outofAmmoAudioStream : AudioStreamPlayer2D = $Sounds/NeedsAmmoAudioStream
@onready var _reloadGunAudioStream : AudioStreamPlayer2D=  $Sounds/ReloadAudioStream
@onready var playerSkin : PlayerSkinManager = $PlayerSkinNode

#bools go here i guess:
@onready var can_shoot : bool = true



@export var recoil_strength: float = 100.0  # tweak this value for push force
@export var recoil_decay: float = 80.0       # how fast recoil decay

var recoil_velocity: Vector2 = Vector2.ZERO

@export var max_camzoom :float = 0.4
@export var min_camzoom :float = 1.0
@export var zoom_speed : float = 0.1 
@onready var target_zoom : float = 0.6 
@onready var cur_camzoom :float = target_zoom
@onready var viewBobbing : float = 2

func _ready():
	super._ready()
	isAffectable = true
	
	call_deferred("_equipGun")
	GameManager.player_health = health
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


func _physics_process(delta: float) -> void:
	adjustCameraZoom(delta)
	
	GameManager.player_x= global_position.x
	GameManager.player_y= - global_position.y
	
	_lifebar.value = health
	
	if _canmove:
		direction_and_action_handler()
		update_player_motion(delta)
		mouse_actions_handler()

#PlayerBehavior Methods

func direction_and_action_handler(): #handles direction and current actions
	if !_iswalking and !_isbackwards:
		playerSkin._setAction("Idle")
		playerSkin._setBackwards(false)
	elif !_iswalking and _isbackwards:
		playerSkin._setAction("Idle")
		playerSkin._setBackwards(true)
	elif _iswalking and !_isbackwards:
		playerSkin._setAction("Walking")
		playerSkin._setBackwards(false)
	elif _iswalking and _isbackwards:
		playerSkin._setAction("Walking")
		playerSkin._setBackwards(true)
		

		
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	_isbackwards = mouse_dir.y < 0
	
	var _flipGun = mouse_dir.x <0
	if _gun:
		_gun._flipGun(_flipGun)
		_gun.z_index = -1 if _isbackwards else 0

func update_player_motion(delta:float): #handles player current velocity and movement
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("Walk_right") - Input.get_action_strength("Walk_left")
		input_vector.y = Input.get_action_strength("Walk_down") - Input.get_action_strength("Walk_up")
		
		camera.rotation_degrees = input_vector.x * viewBobbing
		
		if input_vector == Vector2.ZERO and Input.is_action_pressed("Mouse_right"):
			input_vector = get_global_mouse_position() - global_position
		
		# Normalize so diagonal movement isn’t faster
		if input_vector != Vector2.ZERO:
			_iswalking = true
			input_vector = input_vector.normalized()
		else:
			_iswalking = false


		velocity = ((input_vector * speed) + recoil_velocity + pushingforce + pullingforce)

		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
		
		recoil_velocity = recoil_velocity.move_toward(Vector2.ZERO, recoil_decay*delta)
		
		updateExternalForces("push", pushingforce.move_toward(Vector2.ZERO, pushingforce.length() * 3 *delta))
		
		move_and_slide()

func mouse_actions_handler():
	if GameManager.can_shoot:
		if Input.is_action_just_pressed("Mouse_left") and GameManager.ammo > 0 and GameManager.currentEquipedWeaponType != "none" and _gun != null:
			var mouse_pos = get_global_mouse_position()
			var recoil_direction = ( global_position - mouse_pos ).normalized() #player recoiled by shoot
			recoil_velocity = recoil_direction * recoil_strength
			print("just shooted")

		elif Input.is_action_just_pressed("Mouse_left") and GameManager.ammo <= 0 :
			_outofAmmoAudioStream.play()
		elif Input.is_action_just_pressed("DropAction") and GameManager.currentEquipedWeaponType != "none" and _gun != null:
			_dropGun()
	#movement and mouse treatment:
	if Input.is_action_just_pressed("UnlockMouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


#AddTo Methods


func uponDamage():
	GameManager.player_health = health

func Die():
	_canmove = false
	GameManager.can_shoot=false
	


#CameraMethods
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP and event.pressed:
			target_zoom += zoom_speed  # ajusta a intenção
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			target_zoom -= zoom_speed
		target_zoom = clamp(target_zoom, max_camzoom, min_camzoom)

func adjustCameraZoom(delta):
	cur_camzoom = lerp(cur_camzoom, target_zoom, 10 * delta)  # 10 é a velocidade do lerp, ajuste como quiser
	camera.zoom = Vector2.ONE * cur_camzoom


#updateGunMethods
func _equipGun():
	_playReloadSound()
	
	if _gun and is_instance_valid(_gun):
		_gun.queue_free()
		_gun = null
		
	if(GameManager.currentEquipedWeaponType == null or GameManager.currentEquipedWeaponType == "none" ):
		return
		
	var currentGunType = GameManager.currentEquipedWeaponType
	var currentGun = ItemData.weapons[currentGunType]
	_gun = null
	_gun = currentGun["weapon_scene"].instantiate()
	_gun.position = _gunPivot.position
	add_child(_gun)

func _switchGun(newWeapon:String):
	if !(newWeapon in ItemData.weapons.keys()):
		return
		
	var oldWeapon = GameManager.currentEquipedWeaponType
	
	GameManager.currentEquipedWeaponType = newWeapon

	GameManager.ammoMax = ItemData.weapons[newWeapon]["max_ammo"]
	var newCurrentAmmo:int 
	
	if oldWeapon != "none" and oldWeapon != null:
		newCurrentAmmo = floor(( GameManager.ammo * ItemData.weapons[newWeapon]["max_ammo"])/ItemData.weapons[oldWeapon]["max_ammo"])
	else: 
		newCurrentAmmo = ItemData.weapons[newWeapon]["max_ammo"]
		
	GameManager.ammo = newCurrentAmmo
	_equipGun()
	return oldWeapon

func _dropGun():
	var droppedgunKey: String = GameManager.currentEquipedWeaponType
	GameManager.currentEquipedWeaponType = "none"
	_equipGun()
	var newdroppedgun :Pickable= preload("res://Scenes/items/pickable_item.tscn").instantiate()
	newdroppedgun.global_position = global_position
	newdroppedgun.PickableName = droppedgunKey
	newdroppedgun.setItemType("WEAPON")
	get_tree().current_scene.add_child(newdroppedgun)
	newdroppedgun.reloadTexture()

#SoundMethods
func _playReloadSound():
	_reloadGunAudioStream.pitch_scale = randf_range(0.5, 0.8)
	_reloadGunAudioStream.play()

#TimerMethods
func _on_regen_timer_timeout() -> void:
	health += 3


#GetMethods
func getRandomPlayerAreaCoordinates() -> Vector2:
	var shape : CircleShape2D = $PlayerArea2D/CollisionShape2D.shape
	var randomRadius = shape.radius * sqrt(randf())
	var randomAngle = randf() * TAU
	var coordinates = Vector2(randomRadius * cos(randomAngle) , randomRadius * sin(randomAngle))
	var global_coordinates = _PlayerArea.to_global(coordinates)
	return global_coordinates
	
