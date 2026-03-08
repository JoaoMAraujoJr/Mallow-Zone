extends Control
class_name DraggableItemPreview

@export var max_rotation: float = 25.0
@export var rotation_speed: float = 3.0
@export var velocity_threshold: float = 20.0

func _physics_process(delta: float) -> void:
	var mouse_vel := Input.get_last_mouse_velocity()
	var target_rotation := 0.0
	
	if mouse_vel.x > velocity_threshold:
		target_rotation = max_rotation
	elif mouse_vel.x < -velocity_threshold:
		target_rotation = -max_rotation
	
	rotation_degrees = lerp(rotation_degrees, target_rotation, rotation_speed * delta)
