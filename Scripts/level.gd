extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_enemy_timer_timeout() -> void:
	if Global.enemySpeed < 500.0:
		Global.enemySpeed +=10.0
	pass # Replace with function body.
