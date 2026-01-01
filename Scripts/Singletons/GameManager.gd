extends Node
@warning_ignore("unused_signal")
signal skin_changed(new_skin: String)

var currentSaveSlot = 1

var ammoMax : int = 0
var ammo : int = ammoMax
var kills : int = 0
var enemySpeed: float = 50.0
var player_health : int = 100
var can_shoot: bool = true

var thisPlayer : Player
var weatherManager : WeatherManager

#Pause Menu:
var pauseMenuScene :PackedScene = load("res://Scenes/UI/pause_menu/pause_menu.tscn")

@onready var pause_menu :PauseMenu
var canPause:bool = true
var isPaused:bool = false


#current
var currentSpawnedChunks :={}
var currentEquipedWeaponType : String = "none"
var currentPlayerSkin: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func pause():
	if not canPause:
		return

	ensure_pause_menu()

	isPaused = !isPaused

	if isPaused:
		get_tree().paused = true
		pause_menu.show()
		pause_menu.AppearAnimPlayer.play("Show")
	else:
		pause_menu.AppearAnimPlayer.play_backwards("Show")
		get_tree().paused = false

func ensure_pause_menu():
	var root := get_tree().get_root()

	# tenta achar um PauseMenu já existente
	if pause_menu == null or not is_instance_valid(pause_menu):
		pause_menu = root.find_child("PauseMenu", true, false)

	# se não existir, instancia
	if pause_menu == null:
		pause_menu = pauseMenuScene.instantiate()
		pause_menu.name = "PauseMenu"
		root.add_child(pause_menu) # NÃO use call_deferred
		pause_menu.hide()

func _input(event):
	if event.is_action_pressed("Pause"):
		pause()
	if event.is_action_pressed("SaveGameDebug"):
		saveDataOnSlot(currentSaveSlot)
	if event.is_action_pressed("UnlockMouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("SaveGameDebug"):
		saveDataOnSlot(currentSaveSlot)


func saveDataOnSlot(slot:int):
	var saveData = {
		"player" : thisPlayer,
		"current_ammo": ammo,
		"player_skin": currentPlayerSkin,
		"player_equiped_weapon_type":  currentEquipedWeaponType,

	}
	var dir = "user://saves/"
	DirAccess.make_dir_recursive_absolute(dir)
	var file_path = dir + "save_%d.json" % slot
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(saveData))
		file.close()
		print("game was saved on slot " + str(slot))
	
