extends CharacterBody2D

signal change_on_boss_status(BossName:String  ,currentHP:int ,IsOnBoss:bool, IsBossDefeated: bool)

@onready var _carAnimatedSprite:AnimatedSprite2D = $CarAnimatedSprite
@onready var _motorAudio:AudioStreamPlayer2D = $MotorSoundStream
@onready var _brainSprite : Sprite2D = $BrainMask/Sprite2D
@onready var maxHp : int = BossManager.BossList["Ominous Car"]["maxHP"]
@onready var currentHp:= maxHp
@onready var _effectHandler := $EffectHandler

@export var ThrowableScene : PackedScene
@export var ExplosioParticle : PackedScene

var frontOpen: bool = false
var backOpen: bool = false

@onready var _playerdetectArea := $PlayerDetectorArea
@onready var _hitdetectArea := $PlayerHitArea
@onready var _forwardmarker := $Forward
@onready var _backwardmarker :=$Backward

@onready var _animplayer_car := $CarAnimationPlayer
@onready var _animplayer_brain:=$BrainAnimationPlayer

@onready var _cooldownTopickDir := $Timers/CooldownTopickDirection
@onready var _cooldownTopickRotation := $Timers/CooldownTopickRotation
@onready var _backwardsDetector := $backwardsDetector
@onready var _canChangeDirection := true


var Playerdir : Vector2 = Vector2.ZERO
@export var OriginalSpeed : float = 210.0
@export var CurrentSpeed : float = OriginalSpeed
@export var Drifting : float = 0.9
@onready var _cooldownmodifier := 1.0

@onready var _toberotation:float
@onready var rotationOffset :float

var _canhit : bool = true
var _isOnBoost = false
@onready var _canpickPlayerLocation : bool= true

enum DirectionStateMachine{
	FORWARD,BACKWARD
}


enum ActionStateMachine{
	ATTACKING,EXPOSED,ATTACKINGANDEXPOSED,PROTECTED
}

var currentDirection : DirectionStateMachine = DirectionStateMachine.FORWARD
var currentAction


func _ready() -> void:
	_carAnimatedSprite.material.set_shader_parameter("flash_white", false)
	_brainSprite.material.set_shader_parameter("flash_white", false)
	_carAnimatedSprite.z_index = 0
	BiomeManager.currentBiome = BossManager.BossList["Ominous Car"]["BossBiome"]
	self.change_on_boss_status.connect(BossManager.change_on_boss_status_received)
	emit_signal("change_on_boss_status","Ominous Car",currentHp,true,false)
	
	pass # Replace with function body.

func _process(delta: float) -> void:
	_updateDirection()  # nova função
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
	if currentDirection == DirectionStateMachine.FORWARD:
		dirVector = (_forwardmarker.global_position - global_position).normalized()
		var _newvelocity = dirVector * CurrentSpeed
		velocity = lerp(velocity, _newvelocity , delta*2)
		rotationOffset = deg_to_rad(-90)
	elif currentDirection == DirectionStateMachine.BACKWARD:
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
	
	# Se player entrou na área
	if player_detected and currentDirection == DirectionStateMachine.FORWARD:
		currentDirection = DirectionStateMachine.BACKWARD
		_canChangeDirection = false
		_cooldownTopickDir.start()
	
	# Se player saiu da área
	elif not player_detected and currentDirection == DirectionStateMachine.BACKWARD:
		currentDirection = DirectionStateMachine.FORWARD
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


#===DAMAGE===
func _getHitsApplied() -> void:
	var bodies = _hitdetectArea.get_overlapping_bodies()
	for body in bodies:
		if body != self:
			if body.has_method("addtoPushVelocity"):
				var push_vector: Vector2 = (body.global_position - global_position).normalized() * CurrentSpeed*3
				body.addtoPushVelocity(push_vector)
				_canhit = false
				if body.has_method("addToHealth"):
					body.addToHealth(-int(CurrentSpeed/15))
				$Timers/DamageCoolDown.start()
			elif body.has_method("setHealth"):
				body.setHealth( -int(CurrentSpeed/10 ))


func setHealth(addedAmount : int)-> void:
	_carAnimatedSprite.material.set_shader_parameter("flash_white", true)
	_brainSprite.material.set_shader_parameter("flash_white", true)
	$Timers/TimerToColorModulate.start()
	if (currentHp + addedAmount) <= 0:
		emit_signal("change_on_boss_status","Ominous Car",0,false,true)
		var explosion = ExplosioParticle.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()
	else:
		currentHp += addedAmount
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


func openEcloseDoors(door:String ):
	match door:
		"front":
			if !frontOpen:
				frontOpen = true
				if backOpen:
					currentAction = ActionStateMachine.ATTACKINGANDEXPOSED
					updateActionState()
				else:
					currentAction = ActionStateMachine.EXPOSED
					updateActionState()
				$DamageDetector.monitoring = true
				$DamageDetector.monitorable = true
				_animplayer_brain.play("brainSpawning")
				await _animplayer_brain.animation_finished
				_animplayer_brain.play("brainMode")

			elif frontOpen:

				_animplayer_brain.play_backwards("brainSpawning")
				await _animplayer_brain.animation_finished
				if backOpen:
					currentAction = ActionStateMachine.ATTACKING
					updateActionState()
				else:
					currentAction = ActionStateMachine.PROTECTED
					updateActionState()
				frontOpen = false
			
		"back":
			if !backOpen:
				backOpen = true
				if frontOpen:
					currentAction = ActionStateMachine.ATTACKINGANDEXPOSED
					updateActionState()
				else:
					currentAction= ActionStateMachine.ATTACKING
					updateActionState()

			elif backOpen:
				backOpen = false
				if frontOpen:
					currentAction=ActionStateMachine.EXPOSED
					updateActionState()

				elif !frontOpen:
					currentAction=ActionStateMachine.PROTECTED
					updateActionState()


func updateActionState():
	match currentAction:
		ActionStateMachine.ATTACKING:
			_carAnimatedSprite.play("attacking")
			if _animplayer_car.current_animation != "throwing":
				_animplayer_car.play("throwing")
			$DamageDetector.monitoring = false
			$DamageDetector.monitorable = false
		ActionStateMachine.EXPOSED:
			_animplayer_car.play("driving")
			_carAnimatedSprite.play("exposed")
			$DamageDetector.monitoring = true
			$DamageDetector.monitorable = true
		ActionStateMachine.PROTECTED:
			_animplayer_car.play("driving")
			_carAnimatedSprite.play("protected")
			$DamageDetector.monitoring = false
			$DamageDetector.monitorable = false
		ActionStateMachine.ATTACKINGANDEXPOSED:
			_carAnimatedSprite.play("exposed_and_attacking")
			if _animplayer_car.current_animation != "throwing":
				_animplayer_car.play("throwing")
			$DamageDetector.monitoring = true
			$DamageDetector.monitorable = true

func _boost():
	if _isOnBoost == false :
		_isOnBoost = true
		CurrentSpeed = CurrentSpeed*2
	elif _isOnBoost == true:
		_isOnBoost= false
		CurrentSpeed = OriginalSpeed


func _dropThrowable():
	if ThrowableScene == null:
		return

	var newThrowable :Node2D= ThrowableScene.instantiate()
	newThrowable.global_position = _backwardmarker.global_position
	
	get_tree().current_scene.add_child(newThrowable)

#===SIGNALS FROM TIMERS===
func _on_cooldown_topick_rotation_timeout() -> void:
	_canpickPlayerLocation = true
	pass # Replace with function body.

func _on_cooldown_topick_direction_timeout() -> void:
	_canChangeDirection = true
	pass # Replace with function body.

func _on_to_add_drift_timeout() -> void:
	if Drifting < 2.5:
		Drifting += 0.1

func _on_damage_cool_down_timeout() -> void:
	_canhit = true
	_cooldownmodifier = 1.0

func _on_timer_till_open_front_timeout() -> void: #USED TO OPEN CAR HOOD
	openEcloseDoors("front")
	$Timers/OpenCloseFront_T.wait_time = randf_range(5.0 , 10.0)

func _on_timer_till_open_back_timeout() -> void:
	openEcloseDoors("back")
	$Timers/OpenCloseBack_T.wait_time = randf_range(3.0 , 5.0)

func _on_timer_to_color_modulate_timeout() -> void:
	_carAnimatedSprite.material.set_shader_parameter("flash_white", false)
	_brainSprite.material.set_shader_parameter("flash_white", false)

func _on_motor_sound_stream_finished() -> void:
	_motorAudio.pitch_scale = randf_range(0.4,2.0)
	_motorAudio.play()
	pass # Replace with function body.
