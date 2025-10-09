extends CharacterBody2D

@onready var _carSprite := $carSprite
@onready var _playerdetectArea := $PlayerDetectorArea
@onready var _hitdetectArea := $PlayerHitArea
@onready var _forwardmarker := $Forward
@onready var _backwardmarker :=$Backward

@onready var _cooldownTopickDir := $Timers/CooldownTopickDirection
@onready var _cooldownTopickRotation := $Timers/CooldownTopickRotation
@onready var _backwardsDetector := $backwardsDetector
@onready var _canChangeDirection := true

@onready var _dirtogo := "forward"

var Playerdir : Vector2 = Vector2.ZERO
@export var Speed : float = 120.0
@onready var PushStrenght : float= Speed*4
@export var Drifting : float = 0.9

@onready var _toberotation:float
@onready var rotationOffset :float

var _canhit : bool = true
@onready var _canpickPlayerLocation : bool= true
var _playerInBackward := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_updateDirection()  # nova função
	_updateStrenght()
	_GoinDirection()
	
	if _canhit:
		_getHitsApplied()
	else:
		Speed = -20
	
	_updateCarRotation(delta)
	move_and_slide()

	
func _GoinDirection() ->void:
	var dirVector :Vector2
	if _dirtogo == "forward":
		dirVector = (_forwardmarker.global_position - global_position).normalized()
		velocity = dirVector * Speed  * Drifting
		rotationOffset = deg_to_rad(-90)
	elif _dirtogo == "backward":
		dirVector = (_backwardmarker.global_position - global_position).normalized()
		velocity = dirVector * Speed * Drifting * 0.8
		rotationOffset = deg_to_rad(90)

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

	

func _getHitsApplied() -> void:
	var bodies = _hitdetectArea.get_overlapping_bodies()
	for body in bodies:
		if body == self:
			continue
		if body.has_method("addtoPushVelocity"):
			var push_vector: Vector2 = (body.global_position - global_position).normalized() * PushStrenght
			body.addtoPushVelocity(push_vector)
		else:
			print_debug("%s não tem o método addtoPushVelocity()" % body.name)
			
func _updateStrenght():
	PushStrenght= Speed*Drifting*3


func _updateDirection() -> void:
	if not _canChangeDirection:
		return
	
	var player_detected := false
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


func _on_cooldown_topick_rotation_timeout() -> void:
	_canpickPlayerLocation = true
	pass # Replace with function body.


func _on_cooldown_topick_direction_timeout() -> void:
	_canChangeDirection = true
	pass # Replace with function body.


func _on_to_add_drift_timeout() -> void:
	if Drifting < 2.0:
		Drifting += 0.1
	pass # Replace with function body.
