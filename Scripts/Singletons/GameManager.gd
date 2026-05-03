extends Node
@warning_ignore("unused_signal")
signal skin_changed(new_skin: PlayerSkin)
@warning_ignore("unused_signal")
signal item_picked(item:InventoryItem)

var currentSaveSlot = 1
var cur_settings :SavedSettings

var kills : int = 0
var enemySpeed: float = 50.0


#PlayerData
var thisPlayer : Player
var cur_hp : int = 100
var max_hp : int = 100
var ui_backpack : BackpackInventory
var cur_inventory :Array[InventoryItem] =[]
var can_shoot: bool = true
var ammoMax : int = 0
var ammo : int = ammoMax
var gold_wallet : int = 0

var weatherManager : WeatherManager

#Pause Menu:
var pauseMenuScene :PackedScene = load("res://Scenes/UI/pause_menu/pause_menu.tscn")

@onready var pause_menu :PauseMenu
var canPause:bool = true
var isPaused:bool = false


#current
var currentSpawnedChunks :={}
var currentEquipedWeaponType : String = "none"
var cur_skin: PlayerSkin = load("res://Scripts/Resources/PlayerSkins/normal_skin.tres")


func _ready() -> void:
	load_settings()



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
	if event.is_action_pressed("UnlockMouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func load_from_current_save():
	if SaveManager.current_save:
		max_hp = SaveManager.current_save.max_hp
		cur_hp = SaveManager.current_save.cur_hp
		if SaveManager.current_save.cur_skin:
			cur_skin = SaveManager.current_save.cur_skin
		else:
			cur_skin = load("res://Scripts/Resources/PlayerSkins/normal_skin.tres")
		cur_inventory =SaveManager.current_save.inventory
		print(str(cur_skin))
		currentEquipedWeaponType = SaveManager.current_save.cur_weapon
		gold_wallet = SaveManager.current_save.money
		if currentEquipedWeaponType in ItemData.weapons:
			ammo = ItemData.weapons[currentEquipedWeaponType]["max_ammo"]
			ammoMax = ItemData.weapons[currentEquipedWeaponType]["max_ammo"]
		if SaveManager.current_save.cur_place != null:
			LevelManager.cur_place = SaveManager.current_save.cur_place
		else: 
			LevelManager.cur_place = preload("res://Scripts/Resources/Places/Biomes/GrassLands.tres")


func save_and_apply_settings(new_settings: SavedSettings):
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("settings"):
		dir.make_dir("settings")
	cur_settings = new_settings
	var path:= "user://settings/saved_settings.tres"
	ResourceSaver.save(new_settings,path)
	apply_settings()
func load_settings():
	var path = "user://settings/saved_settings.tres"
	if FileAccess.file_exists(path):
		var loaded_res = ResourceLoader.load(path)
		if loaded_res is SavedSettings:
			cur_settings = loaded_res
			apply_settings()
			print("Settings loaded successfully")
			return
	# If file doesn't exist or load failed:
	print("No settings found, creating default")
	cur_settings = SavedSettings.new()
	save_and_apply_settings(cur_settings)
func apply_settings():
	if not cur_settings: return
	
	# --- APLICAR VÍDEO ---
	var res_parts = cur_settings.res.split("x")
	if res_parts.size() == 2:
		var width = int(res_parts[0])
		var height = int(res_parts[1])
		# Define o tamanho da janela e a escala interna
		get_window().content_scale_size = Vector2i(width, height)
		DisplayServer.window_set_size(Vector2i(width, height))
	
	# Fullscreen
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if cur_settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	
	# --- APLICAR ÁUDIO ---
	_set_bus_volume("Master", cur_settings.master_vol)
	_set_bus_volume("Music", cur_settings.music_vol)
	_set_bus_volume("Ambience", cur_settings.ambience_vol)
	_set_bus_volume("SFX", cur_settings.sfx_vol)
	_set_bus_volume("SFXReverb", cur_settings.sfx_vol)

	print("Settings applied to engine")

# Função auxiliar para o áudio
func _set_bus_volume(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var vol_linear = value / 100.0
		AudioServer.set_bus_volume_linear(bus_index, vol_linear)
