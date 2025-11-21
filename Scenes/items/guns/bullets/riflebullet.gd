extends RigidBody2D

@onready var speed: float = 500.0
@onready var direction: Vector2 
@onready var _area: Area2D = $damageArea
@onready var damage := -2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	linear_velocity = direction * speed

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	linear_velocity = dir * speed
	$Sprite2D.rotate(dir.angle())


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.


func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Damageble") and area.get_parent().has_method("setHealth") :
		area.get_parent().setHealth(damage)
		queue_free()
	if area.get_parent().is_in_group("Interactable"):
		area.get_parent().TurnedOn = true
		queue_free()
	pass # Replace with function body.
