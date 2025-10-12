extends CharacterBody2D

#spawnable
@export var SpawnAtFixedPosition : bool = false

@onready var _vision: Area2D = $EnemyVision
@onready var _hitbox: Area2D = $EnemyHitbox
@onready var _damage_timer: Timer = $DamageTimer 
@onready var _colorchangetimer : Timer = $SelfModulateTimer
@onready var _lightcolor : PointLight2D = $PointLight2D
@onready var _sprite2d : Sprite2D = $Sprite2D
@onready var _deathAudioStream : AudioStreamPlayer2D = $DeathAudioStream
@onready var _damageAudioStream : AudioStreamPlayer2D = $DamageAudioStream
@onready var _effectHandler : EffectHandler = $EffectHandler

@onready var can_damage : bool = true
@onready var is_dead : bool = false
@export var damage: int = -10

var bloodscene = preload('res://Scenes/particles.tscn')


@export var hp: int = 3
@onready var maxHp:int = hp

var knockbackvelocity : Vector2 = Vector2.ZERO
var followMode: bool = false
var SPEED: float = Global.enemySpeed

func _ready() -> void:
	var burning = preload("res://Scripts/Resources/Effects/burning.tres")
	addEffect(burning)

func _physics_process(delta: float) -> void:
	if followMode:
		# exemplo simples: ir em direção ao primeiro corpo na visão
		var bodies = _vision.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("PlayerArea") and !is_dead:
				var direction = (body.global_position - global_position).normalized()
				velocity = direction * SPEED + knockbackvelocity
				break
				
		if can_damage and !is_dead:
			var hit_bodies = _hitbox.get_overlapping_bodies()
			for body in hit_bodies:
				if body.is_in_group("PlayerArea"):
					var hitdirection =  ( global_position - body.global_position ).normalized()
					if body.has_method("addToHealth"):
						body.addToHealth(damage)
						knockbackvelocity += hitdirection * SPEED  *2
						# inicia cooldown
						can_damage = false
						_damage_timer.start()
						break
					
	else:
		velocity = Vector2.ZERO
	knockbackvelocity = knockbackvelocity.move_toward(Vector2.ZERO, SPEED*delta)
	
	move_and_slide()

func _on_enemy_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		followMode = true

func _on_enemy_vision_body_exited(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		followMode = false

func _on_damage_timer_timeout() -> void:
	can_damage = true


func setHealth(addedAmount : int)-> void:
	hp += addedAmount
	
	if hp <= 0 and !is_dead:
		is_dead = true
		can_damage = false

		# spawn blood
		var bloodsOnDeath = bloodscene.instantiate()
		bloodsOnDeath.global_position = global_position
		get_tree().current_scene.add_child(bloodsOnDeath)

		#remove visuasl
		_lightcolor.queue_free()
		_sprite2d.queue_free()
		$LightOccluder2D.queue_free()
		$CollisionShape2D.queue_free()
		# increase kill count
		Global.kills += 1 

		# play death sound
		_deathAudioStream.pitch_scale = randf_range(0.9, 1.9)
		_deathAudioStream.play()

		# connect signal to free after sound
		_deathAudioStream.connect("finished", Callable(self, "_killSelf"))
		return
	
	_damageAudioStream.pitch_scale = randf_range(0.2,1.2)
	_damageAudioStream.play()

	var bloods = bloodscene.instantiate()
	bloods.global_position = global_position
	get_tree().current_scene.add_child(bloods)
	
	if _lightcolor != null:
		_colorchangetimer.start()
		_lightcolor.color = Color(1.0, 1.0, 1.0, 0.392)
	if _sprite2d != null:
		_sprite2d.texture = load("res://Assets/player/monster_damaged.png")# pinta de branco

func _on_self_modulate_timer_timeout() -> void:
	if _lightcolor == null:
		return
	_lightcolor.color = Color(1.0, 0.0, 0.0, 0.686)
	_sprite2d.texture=  load("res://Assets/player/monster.png")
	pass # Replace with function body.

func _killSelf ():
	queue_free()

func _on_death_audio_stream_finished() -> void:
	_killSelf()
	pass # Replace with function body.


func _getSpawnAtFixedPosition() ->bool:
	return SpawnAtFixedPosition

func addEffect(effect : Effect):
	_effectHandler.addEffect(effect)
