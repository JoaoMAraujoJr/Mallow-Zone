extends StaticBody2D

var onScreen:bool = true
@onready var area2d :Area2D = $Area2D
@onready var maxdistance = $Area2D/CollisionShape2D.shape.radius

var affected_bodies := {}

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_deltawwwwwwwww: float) -> void:
	if !onScreen:
		return
		
	for body in affected_bodies.keys():
		if !is_instance_valid(body):
			continue

		var distance = body.global_position.distance_to(global_position)
		var t = clamp(distance / maxdistance, 0.0, 1.0)

		# Ajuste de influência (0–2)
		t *= 2.0

		# Suavização da curva
		var smooth := ease(t, 2.5)

		# Intensidade final
		var scale_value := (1.0 - smooth) * 0.25

		body.scale = Vector2.ONE * (1.0 + scale_value)




func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	onScreen= true
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	onScreen= false
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.scale = Vector2.ONE
		affected_bodies.erase(body)
		print(body.name + " now has the scale of " + str(body.scale))
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body not in affected_bodies:
			affected_bodies[body] = {}
		affected_bodies[body]["originalScale"] = body.scale
	pass # Replace with function body.
