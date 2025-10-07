extends Node2D

@onready var particles :GPUParticles2D = $GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particles.one_shot = true   # ensures it plays only once
	particles.emitting = true   # start the effect
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
	pass # Replace with function body.
