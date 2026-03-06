extends CharacterBody2D
class_name CharacterDamageable


@export var max_health: int = 20
@export var health: int = 20 :
	set(value):
		health = clamp(value, 0, max_health)
	get():
		return health

var isImortal : bool = false
var isAlive : bool = true
var isAffectable : bool = true

var _effectHandler : EffectHandler




func _ready() -> void:
	_effectHandler = find_child("EffectHandler")
	
	if isAffectable and _effectHandler == null:
		_effectHandler = EffectHandler.new()
		_effectHandler.name = "EffectHandler"
		add_child(_effectHandler)

func addToHealth(i:int) -> void:
	if isImortal:
		return
	health += i
	uponDamage()
	if health <= 0:
		isAlive = false
		Die()

func addEffectToSelf(effect : Effect):
	if isAffectable:
		print("added effect")
		_effectHandler.addEffect(effect)

func uponDamage():
	push_error("UponDamage() Has Not Been Implemented for This Damageable")
	pass

func Die():
	push_error("Death (Die()) Not Implemented for This Damageable")
	pass
