extends Node2D
class_name EffectHandler

@export var CurrentEffectsList :Array[Effect]
@onready var CurrentEffectsLifetimes: Array[Timer]
@onready var _timer: Timer = $Timer

#func _ready():
#	add_child(_timer)
#	_timer.wait_time = 1.0
#	_timer.autostart = true
#	_timer.timeout.connect(_on_timer_timeout)

func addEffect(effect:Effect):
	for i in range(CurrentEffectsList.size()):
		if CurrentEffectsList[i].name == effect.name:
			CurrentEffectsLifetimes[i].start()
			return
			
	var newTimer = Timer.new()
	newTimer.wait_time = effect.duration
	newTimer.one_shot = true
	newTimer.autostart = true
	
	add_child(newTimer) 
	
	newTimer.timeout.connect(removeEffect.bind(effect, newTimer)) 
	
	CurrentEffectsList.append(effect)
	CurrentEffectsLifetimes.append(newTimer)

func removeEffect (effect : Effect , timer : Timer):
	var i = CurrentEffectsLifetimes.find(timer)
	
	if i != -1:
		print("the " + effect.name + " effect wore off")
		CurrentEffectsList.remove_at(i)
		CurrentEffectsLifetimes.remove_at(i)
		resetSpeedDebuff()
		timer.queue_free()

func applyEffects():
	if CurrentEffectsList == null:
		return
	for effect in CurrentEffectsList:
		applyDamage(- int(effect.damage_per_second))
		resetSpeedDebuff()
		applySpeedDebuff(- effect.slow_percent)
		instantiateParticles( effect.particle)

func applyDamage(damage : int):
	if self.get_parent() == null:
		return
	if self.get_parent().has_method("setHealth"):
		self.get_parent().setHealth(damage)
	if self.get_parent().has_method("addToHealth"):
		self.get_parent().addToHealth(damage)
	if self.get_parent().has_method("_updateBossHealth"):
		self.get_parent()._updateBossHealth(damage)

func applySpeedDebuff(debuff:float):
	if self.get_parent() == null:
		return
	if self.get_parent().has_method("addToSpeed") and self.get_parent().has_method("resetSpeed"):
		self.get_parent().addToSpeed(debuff)

func resetSpeedDebuff():
	if self.get_parent() == null:
		return
	if self.get_parent().has_method("resetSpeed"):
		self.get_parent().resetSpeed()

func instantiateParticles(Particles:PackedScene):
	if Particles == null:
		return
	var newParticles = Particles.instantiate()
	newParticles.global_position = global_position
	get_tree().current_scene.add_child(newParticles)

func _on_timer_timeout() -> void:
	applyEffects()
	_timer.start()
	pass # Replace with function body.
