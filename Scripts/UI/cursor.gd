extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Mouse_left"):
		$cursor.play("click")
		$cursorOutline.play("click")
	elif Input.is_action_just_released("Mouse_left"):
		$cursor.play("default")
		$cursorOutline.play("default")
	
	global_position = get_global_mouse_position()
	pass
	
	
