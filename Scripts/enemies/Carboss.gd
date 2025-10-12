extends CharacterBody2D

signal change_on_boss_status(BossName:String  ,currentHP:int ,IsOnBoss:bool, IsBossDefeated: bool)

@onready var _carSprite :Sprite2D= $carSprite
@onready var _motorAudio:AudioStreamPlayer2D = $MotorSoundStream
@onready var _brainSprite : Sprite2D = $BrainMask/Sprite2D
@onready var maxHp : int = BossManager.BossList["Ominous Car"]["maxHP"]
@onready var currentHp:= maxHp
@onready var _effectHandler := $EffectHandler


@export var ExplosioParticle : PackedScene

const CarSpriteTextures = {
	"BOTH_CLOSED": preload("res://Assets/objects/car/car.png"),
	"FRONT_OPENED": preload("res://Assets/objects/car/car_front_opened.png"),
	"BACK_OPENED": preload("res://Assets/objects/car/car_back_opened.png"),
	"BOTH_OPENED": preload("res://Assets/objects/car/car_both_opened.png"),
}

var _isFrontOpened: bool = false
var _isBackOpened: bool = false

@onready var _playerdetectArea := $PlayerDetectorArea
@onready var _hitdetectArea := $PlayerHitArea
@onready var _forwardmarker := $Forward
@onready var _backwardmarker :=$Backward
@onready var _animplayer_brain:=$BrainAnimationPlayer

@onready var _cooldownTopickDir := $Timers/CooldownTopickDirection
@onready var _cooldownTopickRotation := $Timers/CooldownTopickRotation
@onready var _backwardsDetector := $backwardsDetector
@onready var _canChangeDirection := true

@onready var _dirtogo := "forward"

var Playerdir : Vector2 = Vector2.ZERO
@export var OriginalSpeed : float = 210.0
@export var CurrentSpeed : float = OriginalSpeed
@onready var PushStrenght : float= CurrentSpeed*4
@export var Drifting : float = 0.9
@onready var _cooldownmodifier := 1.0

@onready var _toberotation:float
@onready var rotationOffset :float

var _canhit : bool = true
var _isOnBoost = false
@onready var _canpickPlayerLocation : bool= true
var _playerInBackward := false


func _ready() -> void:
	_carSprite.material.set_shader_parameter("flash_white", false)
	_brainSprite.material.set_shader_parameter("flash_white", false)
	_carSprite.z_index = 0
	$Timers/TimerTillOpenFront.start()
	Global.currentbiome = "asphalt"
	self.change_on_boss_status.connect(BossManager.change_on_boss_status_received)
	emit_signal("change_on_boss_status","Ominous Car",currentHp,true,false)
	
	pass # Replace with function body.

func _process(delta: float) -> void:
	_updateDirection()  # nova função
	_updateStrenght()
	_GoinDirection(delta)
	
	if _canhit:
		_getHitsApplied()
	else:
		_cooldownmodifier = lerp( _cooldownmodifier , 0.0 , delta )
		velocity =(_forwardmarker.global_position - global_position).normalized() * CurrentSpeed * _cooldownmodifier
	
	_updateCarRotation(delta)
	move_and_slide()

#===MOVEMENT===
func _GoinDirection(delta:float) ->void:
	var dirVector :Vector2
	if _dirtogo == "forward":
		dirVector = (_forwardmarker.global_position - global_position).normalized()
		var _newvelocity = dirVector * CurrentSpeed
		velocity = lerp(velocity, _newvelocity , delta*2)
		rotationOffset = deg_to_rad(-90)
	elif _dirtogo == "backward":
		dirVector = (_backwardmarker.global_position - global_position).normalized()
		var _newvelocity  = dirVector * CurrentSpeed * 0.8
		velocity = lerp(velocity, _newvelocity , delta*2)
		rotationOffset = deg_to_rad(90)

func _updateDirection() -> void:
	if not _canChangeDirection:
		return
	
	var player_detected := false
	for body in _backwardsDetector.get_overlapping_bodies():
		if body.is_in_group("PlayerArea"):
			player_detected = true
			break
	
	for body in _backwardsDetector.get_overlapping_bodies():
		if body.is_in_group("PlayerArea"):
			player_detected = true
			break
	
	# Se player entrou na área
	if player_detected and not _playerInBackward:
		_playerInBackward = true
		_dirtogo = "backward"
		_canChangeDirection = false
		_cooldownTopickDir.start()
	
	# Se player saiu da área
	elif not player_detected and _playerInBackward:
		_playerInBackward = false
		_dirtogo = "forward"
		_canChangeDirection = false
		_cooldownTopickDir.start()

func _updateCarRotation(delta: float) -> void:
	if not _canpickPlayerLocation:
		# continua ajustando lentamente até chegar na rotação desejada
		rotation = lerp_angle(rotation, _toberotation, delta * Drifting) # pode ajustar a velocidade
		return

	for body in _playerdetectArea.get_overlapping_bodies():
		if body.is_in_group("PlayerArea"):
			Playerdir = (body.global_position - global_position).normalized()
			if Playerdir != Vector2.ZERO:
				_toberotation = Playerdir.angle() + rotationOffset
				_canpickPlayerLocation = false
				_cooldownTopickRotation.start()
			break

func _boost():
	if _isOnBoost == false :
		_isOnBoost = true
		CurrentSpeed = CurrentSpeed*2
	elif _isOnBoost == true:
		_isOnBoost= false
		CurrentSpeed = OriginalSpeed
		
#===DAMAGE===
func _getHitsApplied() -> void:
	var bodies = _hitdetectArea.get_overlapping_bodies()
	for body in bodies:
		if body != self:
			if body.has_method("addtoPushVelocity"):
				var push_vector: Vector2 = (body.global_position - global_position).normalized() * PushStrenght
				body.addtoPushVelocity(push_vector)
				_canhit = false
				if body.has_method("addToHealth"):
					body.addToHealth(-int(CurrentSpeed/10))
				$Timers/DamageCoolDown.start()
			elif body.has_method("setHealth"):
				body.setHealth( -int(CurrentSpeed/10 * 2))

func _updateStrenght():
	PushStrenght= CurrentSpeed*3

func _updateBossHealth(addto: int):
	_carSprite.material.set_shader_parameter("flash_white", true)
	_brainSprite.material.set_shader_parameter("flash_white", true)
	$Timers/TimerToColorModulate.start()
	if (currentHp + addto) <= 0:
		emit_signal("change_on_boss_status","Ominous Car",0,false,true)
		var explosion = ExplosioParticle.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()
	else:
		currentHp += addto
		emit_signal("change_on_boss_status","Ominous Car",currentHp,true,false)

#===EFFECTS===
func addEffectToSelf(effect : Effect):
	_effectHandler.addEffect(effect)

func addToSpeed(Added :float):
	var percentage = 1 + Added
	CurrentSpeed *= percentage 
func resetSpeed():
	if CurrentSpeed != OriginalSpeed :
		CurrentSpeed = OriginalSpeed


#===ACTIONS===
func openCloseFront():
	if !_isFrontOpened:
		_isFrontOpened = true
		if _isBackOpened:
			_carSprite.texture=CarSpriteTextures.BOTH_OPENED
		else:
			_carSprite.texture=CarSpriteTextures.FRONT_OPENED
		$DamageDetector.monitoring = true
		$DamageDetector.monitorable = true
		_animplayer_brain.play("brainSpawning")
		await _animplayer_brain.animation_finished
		_animplayer_brain.play("brainMode")

	elif _isFrontOpened:
		_isFrontOpened = false
		_animplayer_brain.play_backwards("brainSpawning")
		await _animplayer_brain.animation_finished
		$DamageDetector.monitoring = false
		$DamageDetector.monitorable = false
		if _isBackOpened:
			_carSprite.texture=CarSpriteTextures.BACK_OPENED
		else:
			_carSprite.texture=CarSpriteTextures.BOTH_CLOSED

#===SIGNALS FROM TIMERS===
func _on_cooldown_topick_rotation_timeout() -> void:
	_canpickPlayerLocation = true
	pass # Replace with function body.

func _on_cooldown_topick_direction_timeout() -> void:
	_canChangeDirection = true
	pass # Replace with function body.

func _on_to_add_drift_timeout() -> void:
	if Drifting < 1.5:
		Drifting += 0.1
	pass # Replace with function body.

func _on_damage_cool_down_timeout() -> void:
	_canhit = true
	_cooldownmodifier = 1.0
	pass # Replace with function body.

func _on_timer_till_close_front_timeout() -> void: #USED TO CLOSE CAR HOOD
	openCloseFront()
	$Timers/TimerTillOpenFront.start()

func _on_timer_till_open_front_timeout() -> void: #USED TO OPEN CAR HOOD
	openCloseFront()
	$Timers/TimerTillCloseFront.start()
	pass # Replace with function body.

func _on_timer_to_color_modulate_timeout() -> void:
	_carSprite.material.set_shader_parameter("flash_white", false)
	_brainSprite.material.set_shader_parameter("flash_white", false)

#===OTHER SIGNALS===
func _on_damage_detector_area_entered(area: Area2D) -> void: #APPLY DAMAGE
	if area.is_in_group("Bullet"):
		_updateBossHealth(area.get_parent().damage)

	pass # Replace with function body.


func _on_motor_sound_stream_finished() -> void:
	_motorAudio.pitch_scale = randf_range(0.4,2.0)
	_motorAudio.play()
	pass # Replace with function body.
