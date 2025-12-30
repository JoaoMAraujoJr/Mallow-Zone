extends CanvasLayer
class_name LoadingScreen

var TobeLoaded :String = LoadManager.current_to_be_load_scene
@onready var progressBar :TextureProgressBar = $TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if TobeLoaded != null:
		ResourceLoader.load_threaded_request(TobeLoaded)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !TobeLoaded:
		return
	var progressArray :Array = []
	ResourceLoader.load_threaded_get_status(TobeLoaded,progressArray)
	progressBar.value = progressArray[0]* progressBar.max_value
	
	if progressArray[0] == 1:
		var LoadedScene = ResourceLoader.load_threaded_get(TobeLoaded)
		get_tree().change_scene_to_packed(LoadedScene)
