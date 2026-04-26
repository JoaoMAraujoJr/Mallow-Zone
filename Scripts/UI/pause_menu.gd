extends CanvasLayer
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
	queue_free()

func _on_resume_pressed() -> void:
	if canUnpause:
		unPauseGame()
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	if GameManager.canPause and GameManager.isPaused:
		get_tree().quit()
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	if GameManager.canPause and GameManager.isPaused:
		unPauseGame()
		LoadManager.LoadScene("res://Scenes/UI/main_menu/new_main_menu.tscn")
	pass # Replace with function body.
