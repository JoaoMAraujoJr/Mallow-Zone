extends Control
class_name PauseMenu

@onready var AppearAnimPlayer:AnimationPlayer=$AppearAnimPlayer
@export var canUnpause:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.







func unPauseGame():
	GameManager.canPause= true
	GameManager.isPaused=true
	GameManager.pause()
	get_tree().paused = false

func _on_resume_pressed() -> void:
	if canUnpause:
		unPauseGame()
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
