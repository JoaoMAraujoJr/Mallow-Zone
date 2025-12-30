extends StaticBody2D

@onready var _vision: Area2D = $EnemyVision
@onready var _hitbox: Area2D = $EnemyHitbox
@onready var _damage_timer: Timer = $DamageTimer 

var target_scale: Vector2 = Vector2.ZERO
var shrink_speed: float = 0.05  # unidades de scale por segundo
var min_scale_threshold: float = 0.05  # quando a escala for menor que isso, deleta o node


@onready var can_damage : bool = true
@export var damage: int = -30

var bloodscene = preload('res://Scenes/particles.tscn')


@export var hp: int = 999

var knockbackvelocity : Vector2 = Vector2.ZERO
var pushingforce: Vector2 = Vector2.ZERO
var followMode: bool = false
var SPEED: float = 0

func _ready() -> void:
	scale *= randf_range(1.0,2.0)
func _physics_process(delta: float) -> void:
	
	scale = scale.move_toward(target_scale, shrink_speed * delta)

	# checa se ficou pequeno demais
	if scale.x <= min_scale_threshold and scale.y <= min_scale_threshold:
		queue_free()

		queue_free()
	if followMode:
		var bodies = _vision.get_overlapping_bodies()
		for body in bodies:
			if body is CharacterEntity:

				# força de sucção no player
				var offset: Vector2 = global_position - body.global_position
				var distance = max(offset.length(), 1.0) # evita divisão por zero
				var force = clamp(1000.0 / distance, 2, 20) # limite mínimo e máximo
				
				var pullingVector : Vector2 = offset.normalized() * force 
				pullingVector += body.pullingforce
				body.updateExternalForces("pull",pullingVector)
				break
				
		var enemy_areas= _hitbox.get_overlapping_areas()
		for area in enemy_areas:		
			if area.is_in_group("Enemy"):
				var enemy = area.get_parent()
				if enemy.has_method("setHealth"):
					enemy.setHealth(-10)
					
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
		pass
	


func _on_enemy_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		followMode = true


func _on_enemy_vision_body_exited(body: Node2D) -> void:
	if body is Player:
		body.updateExternalForces("pull",Vector2.ZERO)
		followMode = false

func _on_damage_timer_timeout() -> void:
	can_damage = true
