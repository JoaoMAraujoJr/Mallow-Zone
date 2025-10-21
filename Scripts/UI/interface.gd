extends Control

@onready var ammo : int = GameManager.ammo
@onready var _ammolabel: Label = $InterfaceCanvaLayer/Ammo
@onready var _killslabel: Label = $InterfaceCanvaLayer/Kills
@onready var _coords: Label = $InterfaceCanvaLayer/CoordRadarRect/Coordinates
@onready var _button: TextureButton = $InterfaceCanvaLayer/Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.player_health <= 0:
		_button.visible = true
	else : 		_button.visible = false
	ammo = GameManager.ammo
	_ammolabel.text = "Ammo: " + str(ammo) + "/ " + str(GameManager.ammoMax)
	_killslabel.text= str(GameManager.kills) + " Kills"
	_coords.text = " %.2f \n %.2f" % [GameManager.player_x, GameManager.player_y]
	

	
	
	pass


func _on_button_pressed() -> void:
	GameManager.kills= 0
	GameManager.enemySpeed= 50.0
	GameManager.ammo= GameManager.ammoMax
	GameManager.player_x = 0.0
	GameManager.player_y = 0.0
	GameManager.currentbiome="grasslands"
	BossManager._isOnBoss = false
	BossManager.currentBossName = ""
	get_tree().change_scene_to_file("res://Scenes/Level.tscn")
	pass # Replace with function body.
