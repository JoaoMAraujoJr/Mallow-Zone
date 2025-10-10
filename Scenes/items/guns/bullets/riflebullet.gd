extends CharacterBody2D

@onready var speed: float = 500.0
@onready var direction: Vector2 
@onready var _area: Area2D = $damageArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	velocity = direction * speed * 100 * delta
	move_and_slide()
	var bodies = _area.get_overlapping_bodies()
	for body in bodies: 
		if body.has_method("setHealth"):
			body.setHealth(-1)
			queue_free()
		elif body.is_in_group("Interactable"):
			body.TurnedOn = true
			queue_free()
		


func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	velocity = dir * speed
	$Sprite2D.rotate(dir.angle())


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.
