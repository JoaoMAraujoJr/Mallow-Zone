extends RigidBody2D
class_name Bullet

@export var effect : Effect 
@export var damage : int = 1
@export var speed : float = 100.0
@export var dir: Vector2 



func uponHit()-> void:
#to be implemented
	pass

func die()->void:
	queue_free()

func followTarget()->void:
	linear_velocity = dir.normalized() * speed

func set_dir(dirVector:Vector2):
	if dirVector == Vector2.ZERO:
		die()
	dir = dirVector.normalized()
