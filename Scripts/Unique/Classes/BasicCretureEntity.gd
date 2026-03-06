extends RigidEntity
class_name BasicCreatureEntity

@export_category("Basic Creature")


@export var can_move:bool = true
@export var player_detector : Area2D





@export_category("Behaviour Config")
enum Behaviours {
	SHY,
	FOLLOWER,
	WANDER,
	IDLE,
}

@export var use_basic_behaviours:bool = true
@export var cur_Behaviour : Behaviours
@export var target:PhysicsBody2D
@export_group("Shy Config")
@export var detection_radius :float =0.0
@export var shy_speed_multiplier :float= 1.0


@export_group("Wander Config")
@export var stay_in_place_time:float = 2
@export var wander_speed_multiplier :float = 1.0
@export var curiosity_point:Vector2 = Vector2.ZERO
@export var wander_radius :float=300.0
var wander_stay_timer:Timer =Timer.new()
var wander_timer_to_reach:Timer = Timer.new()
var can_wander :bool = true

@export_group("Follower Config")
@export var predict_margin :float = 20.0
@export var refresh_rate: float = 0.2
@export var follower_target_point:Vector2 = Vector2.ZERO
var target_refresh_rate_timer:Timer =Timer.new()
var can_refresh:bool = true

func _ready() -> void:
	super()
	add_child(wander_stay_timer)
	wander_stay_timer.wait_time = stay_in_place_time
	wander_stay_timer.timeout.connect(func():can_wander=true)
	add_child(target_refresh_rate_timer)
	target_refresh_rate_timer.wait_time = refresh_rate
	target_refresh_rate_timer.timeout.connect(func():can_refresh=true)
	add_child(wander_timer_to_reach)
	wander_timer_to_reach.wait_time = 8.0
	wander_stay_timer.timeout.connect(func():curiosity_point=Vector2.ZERO)
	pass # Replace with function body.





# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if can_move:
		if use_basic_behaviours:
			apply_movement_behaviour()
		pass
		
	pass


func apply_movement_behaviour():
	var movement_vector: Vector2 = Vector2.ZERO
	if can_move:
		match cur_Behaviour:
			Behaviours.SHY:
				if target:
					var dir:Vector2 = (global_position - target.global_position)
					var t = clamp(dir.length() /350.0, 0.0, 1.0)
					var speed_amplifier= 1.0 - t
					movement_vector= dir.normalized() * (speed * shy_speed_multiplier)*speed_amplifier

			Behaviours.WANDER:
				if can_wander:
					if curiosity_point == Vector2.ZERO:
						var radius = randf_range(0.0, wander_radius)
						var angle = randf_range(0.0, TAU)
						curiosity_point = global_position + (Vector2.RIGHT.rotated(angle) * radius)
						wander_timer_to_reach.start()
					var dir :Vector2= curiosity_point - global_position
					if dir.length() < 10:
						wander_timer_to_reach.stop()
						can_wander = false
						wander_stay_timer.start()
						curiosity_point = Vector2.ZERO
					else:
						movement_vector = dir.normalized() * speed* wander_speed_multiplier
			Behaviours.FOLLOWER:
				if target:
					if can_refresh:
						var radius = randf_range(predict_margin/3, predict_margin)
						var angle = randf_range(0.0, TAU)
						follower_target_point = target.global_position + (Vector2.RIGHT.rotated(angle) * radius)
						can_refresh=false
						target_refresh_rate_timer.start()
					var vector_dir = (follower_target_point - global_position)
					if vector_dir.length() > 50:
						movement_vector = vector_dir.normalized() * speed
			Behaviours.IDLE:
				movement_vector = Vector2.ZERO
					
		linear_velocity = movement_vector + pullingforce + pushingforce
	else:
		linear_velocity = pullingforce + pushingforce


func _on_body_entered_detector(body: Node2D) -> void:
	if body is Player:
		if detection_radius == 0.0:
			detection_radius = (body.global_position -global_position).length()
			print(str(detection_radius))
		target = body
	pass # Replace with function body.


func _on_body_exited_detector(body: Node2D) -> void:
	if body is Player:
		target = null
	pass # Replace with function body.
