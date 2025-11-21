extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func explode():
	var explosionPart_Scene :PackedScene = preload("res://Scenes/particles/explosion_particle.tscn")
	var spilledOil_Scene : PackedScene = preload("res://Scenes/objects/asphalt/spilled_oil.tscn")
	
	var oil = spilledOil_Scene.instantiate()
	var explosion = explosionPart_Scene.instantiate()
	oil.global_position = global_position
	explosion.global_position = global_position
	get_tree().current_scene.add_child(oil)
	get_tree().current_scene.add_child(explosion)
	queue_free()
