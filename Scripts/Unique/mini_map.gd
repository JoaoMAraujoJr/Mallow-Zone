extends Control

@onready var minimapSubviewport : SubViewport = $SubViewportContainer/MinimapSubviewport
@onready var camera : Camera2D = $SubViewportContainer/MinimapSubviewport/Camera2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().set_canvas_cull_mask_bit(1,false)
	minimapSubviewport.world_2d = get_viewport().world_2d
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameManager.thisPlayer:
		camera.global_position = GameManager.thisPlayer.global_position
	pass
