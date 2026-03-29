extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CursorManager.set_cursor(UtilityCursor.types.CROSSHAIR)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_enemy_timer_timeout() -> void:

	pass # Replace with function body.
