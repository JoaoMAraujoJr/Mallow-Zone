extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_cursor.cur_cursorType = GameManager.game_cursor.CursorTypeList.CROSSHAIR
	GameManager.game_cursor.matchCursorType()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_enemy_timer_timeout() -> void:
	if Global.enemySpeed < 300.0:
		Global.enemySpeed +=5.0
	pass # Replace with function body.
