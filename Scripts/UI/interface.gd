extends Control

@onready var ammo : int = GameManager.ammo
@onready var _ammolabel: Label = $InterfaceCanvaLayer/Ammo
@onready var _killslabel: Label = $InterfaceCanvaLayer/Kills
@onready var _coords: Label = $InterfaceCanvaLayer/CoordRadarRect/Coordinates

@onready var fpsDisplay :RichTextLabel = $InterfaceCanvaLayer/FPS
@onready var vignette_overlay :Control = $InterfaceCanvaLayer/Vignette
@onready var fisheye_overlay :Control = $FishEyeEffectLayer/eyefish
@onready var phone_overlay : Control = $InterfaceCanvaLayer/Phone
@onready var psxfilters_overlay: Control = $InterfaceCanvaLayer/psx

@export_category("Interface Info")
@export var display_fps:bool = false
@export var vignette : bool = true
@export var fisheye : bool = true
@export var phone : bool = false
@export var psxfilters : bool = true


func _ready() -> void:
	setup_interface()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	fpsDisplay.text = "[shake rate=10 level=20][rainbow freq=1 sat=0.5 val=0.9]"+str(Engine.get_frames_per_second()) + " FPS [/rainbow][/shake]"
	ammo = GameManager.ammo
	_ammolabel.text = "Ammo: " + str(ammo) + "/ " + str(GameManager.ammoMax)
	_killslabel.text= str(GameManager.kills) + " Kills"

	if GameManager.thisPlayer:
		$InterfaceCanvaLayer/Gold.text= str(GameManager.thisPlayer.gold_wallet) + " $"
		_coords.text = "%.2f \n%.2f" % [GameManager.thisPlayer.global_position.x, GameManager.thisPlayer.global_position.y]
	

	
	
	pass


func setup_interface():
	if display_fps == true:
		fpsDisplay.visible = true
	else:
		fpsDisplay.visible = false
	if vignette == true:
		vignette_overlay.visible = true
	else:
		vignette_overlay.visible = false
	if fisheye == true:
		fisheye_overlay.visible = true
	else:
		fisheye_overlay.visible = false
	if phone == true:
		phone_overlay.visible = true
	else:
		phone_overlay.visible = false
	if psxfilters == true:
		psxfilters_overlay.visible = true
	else:
		psxfilters_overlay.visible = false
