extends RigidBody2D

@onready var _startTimer: Timer = $StartTimer
@onready var _animplay: AnimationPlayer = $AnimationPlayer
@onready var _playerDetector: Area2D = $PlayerDetector
@onready var _damageHitbox : Area2D = $damagehitbox
@onready var _damage_timer: Timer = $DamageTimer 
@onready var _deleteItSelf: Timer = $DeleteitSelfTimer
@onready var _audioStream : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var _sawSprite : Sprite2D = $Sprite2D

@export var damage = -20

var canChase: bool = false
var Dir: Vector2 = Vector2.ZERO
@onready var hitCounter := 0 :
	set(new_value):
		hitCounter = clamp(new_value,0,2)
		
	
@onready var can_damage : bool = false
@onready var _itstoped : bool = false

@export var SPEED: float = 500.0

# Texturas independentes (carregadas uma vez)
@export var NORMAL_TEXTURE : Texture2D
@export var BLOODED_TEXTURE : Texture2D
@export var BLOODED_TEXTURE_2 : Texture2D

func _ready() -> void:

	# Faz uma cópia da textura do Sprite para não afetar o modelo base
	_sawSprite.texture = _sawSprite.texture.duplicate()
	_startTimer.start()


func _physics_process(delta: float) -> void:
	
	_update_texture()
	
	
	if _itstoped:
		canChase = false
		SPEED = lerp(SPEED, 0.0, delta * 2.0)  # o "2.0" controla a rapidez com que para
		if SPEED < 1.0:
			SPEED = 0.0  # garante que zere totalmente	
	if canChase:

		linear_velocity = Dir * SPEED
		



func _update_texture() -> void:
	match hitCounter:
		1:
			_sawSprite.texture.diffuse_texture = BLOODED_TEXTURE
		2:
			_sawSprite.texture.diffuse_texture = BLOODED_TEXTURE_2
		0:
			_sawSprite.texture.diffuse_texture = NORMAL_TEXTURE

func _on_startimer_timeout() -> void:
	_damageHitbox.monitoring = true
	canChase = true
	can_damage = true
	_animplay.play("rotating")
	_audioStream.pitch_scale = randf_range(0.3, 0.8)
	_audioStream.play()
	var bodies = _playerDetector.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("PlayerArea"):
			Dir = (body.global_position - global_position).normalized()


func _on_damage_timer_timeout() -> void:
	can_damage = true


func _on_deleteit_self_timer_timeout() -> void:
	print("saw deleted for being too far")
	queue_free()
	pass # Replace with function body.

func _StopSaw() -> void:
	_itstoped = true
	

func _on_time_to_stop_timeout() -> void:
	_animplay.play("stopRotation")
	pass # Replace with function body.


func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		_deleteItSelf.stop()

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		if is_inside_tree() and is_instance_valid(_deleteItSelf):
			if _deleteItSelf.is_inside_tree():
				_deleteItSelf.start()
				


func _on_damagehitbox_body_entered(body: Node2D) -> void:
	if !can_damage:
		return
	
	if body is Player:
		body.addToHealth(damage)
		can_damage = false
		_damage_timer.start()
	elif body.has_method("setHealth") and !body.is_in_group("Boss"):
		body.setHealth(damage)
	else:
		return
	
	hitCounter +=1

	
	return
