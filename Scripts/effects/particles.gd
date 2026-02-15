extends Node2D
class_name DestroyedTreeParticle

@onready var particles :GPUParticles2D = $GPUParticles2D
@onready var tree_texture:Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particles.one_shot = true   # ensures it plays only once
	particles.emitting = true   # start the effect
	if tree_texture:
		particles.texture = tree_texture
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
	pass # Replace with function body.
