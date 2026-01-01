extends CanvasLayer

@onready var Music := $MenuMusic
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.canPause=false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	GameManager.canPause=true
	LoadManager.LoadScene("res://Scenes/Level.tscn")
	pass # Replace with function body.


func _on_menu_music_finished() -> void:
	Music.play()
	pass # Replace with function body.
