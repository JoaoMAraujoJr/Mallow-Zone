# Attach this script to a CharacterBody2D node
extends CharacterBody2D

var bulletscene = preload('res://Scenes/objects/bullet.tscn')
var bulletParticle = preload("res://Scenes/bullet_particle.tscn")

@onready var _iswalking : bool = false
@onready var _isbackwards: bool= false
@onready var _canmove: bool = true

@onready var camera : Camera2D = $Camera2D

@onready var _PlayerArea : Area2D = $PlayerArea2D
@onready var _PlayerCollision : CollisionShape2D = $PlayerCollisionShape
@onready var _flashlight: Node2D = $flashlight
@onready var _lifebar : TextureProgressBar= $LifeBar
@onready var _gunsprite : Sprite2D = $gun
@onready var _gunpoint : Marker2D = $gun/gunpoint
@onready var _animplayer : AnimatedSprite2D = $AnimatedSprite2D
#bools go here i guess:
@onready var can_shoot : bool = true
@onready var isbeingpushed: bool = false


@export var recoil_strength: float = 100.0  # tweak this value for push force
@export var recoil_decay: float = 80.0       # how fast recoil decay
@export var speed: float = 200.0
@export_range(0, 100, 1) var health: int = 100

var pushingforce: Vector2 = Vector2.ZERO
var recoil_velocity: Vector2 = Vector2.ZERO
var max_speed :float = 400.0 
@export var max_camzoom :float = 0.4
@export var min_camzoom :float = 1.0
@export var zoom_speed : float = 0.1 
@onready var target_zoom : float = 0.6 
@onready var cur_camzoom :float = target_zoom

func _ready():
	Global.player_health = health
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


func _physics_process(delta: float) -> void:
	adjustCameraZoom(delta)
	if _canmove:
		if !_iswalking and !_isbackwards:
			_animplayer.play("idle_foward")
		elif !_iswalking and _isbackwards:
			_animplayer.play("idle_backward")
		elif _iswalking and !_isbackwards:
			_animplayer.play("walk_foward")
		elif _iswalking and _isbackwards:
			_animplayer.play("walk_backward")
			
		
		Global.player_x= global_position.x
		Global.player_y= - global_position.y
		
		_lifebar.value = health
		var input_vector = Vector2.ZERO
			# Pega a posição do mouse na world
		var mouse_pos = get_global_mouse_position()
		var flashlightdirection = mouse_pos-_flashlight.global_position
		_flashlight.global_rotation = flashlightdirection.angle()
		_gunsprite.global_rotation= flashlightdirection.angle()
			
		var mouse_dir = (get_global_mouse_position() - global_position).normalized()
		_isbackwards = mouse_dir.y < 0
		
		_gunsprite.flip_v = _isbackwards
		_gunsprite.z_index = -1 if _isbackwards else 0
		
			
			#calcula o recoil velocity do tiro
		if Input.is_action_just_pressed("Mouse_left") and Global.ammo > 0:
			var bulletPart = bulletParticle.instantiate()
			bulletPart.global_position = _gunpoint.global_position
			get_tree().current_scene.add_child(bulletPart)
			var newbullet = bulletscene.instantiate()
			newbullet.position = _gunpoint.global_position
			var bulletdirection = (get_global_mouse_position() - newbullet.global_position).normalized()
			newbullet.set_direction(bulletdirection)
			Global.ammo -= 1
			get_tree().current_scene.add_child(newbullet)
			
			var recoil_direction = ( global_position - mouse_pos ).normalized()
			recoil_velocity = recoil_direction * recoil_strength
			print("this is being recoiled")
		
		#movement and mouse treatment:
		if Input.is_action_just_pressed("UnlockMouse"):
			if Input.mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		
		input_vector.x = Input.get_action_strength("Walk_right") - Input.get_action_strength("Walk_left")
		input_vector.y = Input.get_action_strength("Walk_down") - Input.get_action_strength("Walk_up")
		
		if Input.is_action_pressed("Mouse_right"):
			input_vector = ( get_global_mouse_position() - global_position).normalized()
		# Normalize so diagonal movement isn’t faster
		if input_vector != Vector2.ZERO:
			_iswalking = true
			input_vector = input_vector.normalized()
		else:
			_iswalking = false

		if isbeingpushed:
			velocity = (input_vector * speed + recoil_velocity +pushingforce)
		else:
			velocity = (input_vector * speed + recoil_velocity)
		
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
		
		recoil_velocity = recoil_velocity.move_toward(Vector2.ZERO, recoil_decay*delta)

		move_and_slide()

func  addToHealth(i:int) -> void:
	if health + i >= 100:
		health =100
	elif (health + i < 0) or (health + i == 0):
		health = 0
		_canmove = false
	else : health += i
	
	Global.player_health = health
	
func addToPushingVelocity(pushingVector : Vector2):
	pushingforce += pushingVector
	isbeingpushed = true

func resetPushing():
	pushingforce = Vector2.ZERO
	isbeingpushed = false

func _on_regen_timer_timeout() -> void:
	if health < 100 :
		health += 1
	else:
		health=100


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
