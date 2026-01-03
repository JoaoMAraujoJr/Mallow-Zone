extends Control

@onready var ammo : int = GameManager.ammo
@onready var _ammolabel: Label = $InterfaceCanvaLayer/Ammo
@onready var _killslabel: Label = $InterfaceCanvaLayer/Kills
@onready var _coords: Label = $InterfaceCanvaLayer/CoordRadarRect/Coordinates


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	ammo = GameManager.ammo
	_ammolabel.text = "Ammo: " + str(ammo) + "/ " + str(GameManager.ammoMax)
	_killslabel.text= str(GameManager.kills) + " Kills"
	if GameManager.thisPlayer:
		_coords.text = "%.2f \n%.2f" % [GameManager.thisPlayer.global_position.x, GameManager.thisPlayer.global_position.y]
	

	
	
	pass
