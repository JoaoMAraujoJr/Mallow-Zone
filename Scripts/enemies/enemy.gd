extends CharacterBody2D

@onready var _vision: Area2D = $EnemyVision
@onready var _hitbox: Area2D = $EnemyHitbox
@onready var _damage_timer: Timer = $DamageTimer 
@onready var _colorchangetimer : Timer = $SelfModulateTimer
@onready var _lightcolor : PointLight2D = $PointLight2D
@onready var _sprite2d : Sprite2D = $Sprite2D

@onready var can_damage : bool = true
@export var damage: int = -10

var bloodscene = preload('res://Scenes/particles.tscn')


@export var hp: int = 3

var knockbackvelocity : Vector2 = Vector2.ZERO
var followMode: bool = false
var SPEED: float = Global.enemySpeed


func _physics_process(delta: float) -> void:
	if hp <= 0:
		var bloods = bloodscene.instantiate()
		bloods.global_position = global_position
		get_tree().current_scene.add_child(bloods)
		Global.kills += 1 

		queue_free()
	if followMode:
		# exemplo simples: ir em direção ao primeiro corpo na visão
		var bodies = _vision.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("PlayerArea"):
				var direction = (body.global_position - global_position).normalized()
				velocity = direction * SPEED + knockbackvelocity
				break
				
		if can_damage:
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


func setHealth(damage : int)-> void:
	hp = hp + damage
	_colorchangetimer.start()
	_lightcolor.color = Color(1.0, 1.0, 1.0, 0.392)
	var bloods = bloodscene.instantiate()
	bloods.global_position = global_position
	get_tree().current_scene.add_child(bloods)
	_sprite2d.texture = load("res://Assets/player/monster_damaged.png")# pinta de branco
	
	
func _on_self_modulate_timer_timeout() -> void:
	_lightcolor.color = Color(1.0, 0.0, 0.0, 0.686)
	_sprite2d.texture=  load("res://Assets/player/monster.png")
	pass # Replace with function body.
