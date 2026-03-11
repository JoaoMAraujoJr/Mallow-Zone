extends Node
@warning_ignore("unused_signal")
signal skin_changed(new_skin: PlayerSkin)
signal item_picked(item:InventoryItem)

var currentSaveSlot = 1


var kills : int = 0

var enemySpeed: float = 50.0


#PlayerData
var thisPlayer : Player
var cur_hp : int = 100
var max_hp : int = 100
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
var cur_skin: PlayerSkin = preload("res://Scripts/Resources/PlayerSkins/normal_skin.tres")

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
	if event.is_action_pressed("UnlockMouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


func load_from_current_save():
	if SaveManager.current_save:
		max_hp = SaveManager.current_save.max_hp
		cur_hp = SaveManager.current_save.cur_hp
		cur_skin = SaveManager.current_save.cur_skin
		cur_inventory =SaveManager.current_save.inventory
		print(str(cur_skin))
		currentEquipedWeaponType = SaveManager.current_save.cur_weapon
		gold_wallet = SaveManager.current_save.money
		if currentEquipedWeaponType in ItemData.weapons:
			ammo = ItemData.weapons[currentEquipedWeaponType]["max_ammo"]
			ammoMax = ItemData.weapons[currentEquipedWeaponType]["max_ammo"]
		if SaveManager.current_save.cur_biome != null:
			BiomeManager.currentBiome = SaveManager.current_save.cur_biome
		else: 
			BiomeManager.currentBiome = preload("res://Scripts/Resources/Biomes/GrassLands.tres")
