extends CanvasLayer

@onready var ammo : int = Global.ammo
@onready var _ammolabel: Label = $Ammo
@onready var _killslabel: Label = $Kills
@onready var _coords: Label = $Coordinates
@onready var _button: TextureButton = $Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.player_health <= 0:
		_button.visible = true
	else : 		_button.visible = false
	ammo = Global.ammo
	_ammolabel.text = "Ammo: " + str(ammo) + "/ " + str(Global.ammoMax)
	_killslabel.text= str(Global.kills) + " Kills"
	_coords.text = " %.2f \n %.2f" % [Global.player_x, Global.player_y]
	

	
	
	pass


func _on_button_pressed() -> void:
	Global.kills= 0
	Global.enemySpeed= 50.0
	Global.ammo= Global.ammoMax
	get_tree().change_scene_to_file("res://Scenes/Level.tscn")
	pass # Replace with function body.
