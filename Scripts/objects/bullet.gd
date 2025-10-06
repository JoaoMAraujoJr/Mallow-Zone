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
	var areas = _area.get_overlapping_areas()
	for area in areas: 
		if area.is_in_group("Enemy"):
			var body = area.get_parent()
			body.setHealth(-1)
			queue_free()


func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	velocity = dir * speed
	$Sprite2D.rotate(dir.angle())




func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.
