extends Node

var current_to_be_load_scene :String


func LoadScene(nextScene:String):
	current_to_be_load_scene = nextScene
	call_deferred("_deferred_load_scene")

func _deferred_load_scene():
	get_tree().change_scene_to_file("res://Scenes/UI/Screens/LoadingScreen/loading_screen.tscn")
