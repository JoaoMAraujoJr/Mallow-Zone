extends Node

signal skin_changed(new_skin: String)

var ammoMax : int = 0
var ammo : int = ammoMax
var kills : int = 0
var player_x: float = 0
var player_y: float = 0
var enemySpeed: float = 50.0
var player_health : int = 100
var can_shoot: bool = true

#current
var currentbiome : String = "grasslands"
var currentEquipedWeaponType : String = "none"
var currentPlayerSkin: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	UpdateBiome()
	if Input.is_action_just_pressed("SaveGameDebug"):
		saveDataOnSlot(1)
	pass


func UpdateBiome():
	if !BossManager._isOnBoss:
		if (player_x < 0.0 or player_x > -0.0 or player_y < 0.0 or player_y > -0.0):
			currentbiome = "grasslands"
		if (player_x > 10000.0 or player_x < -10000.0 or player_y > 10000.0 or player_y < -10000.0):
			currentbiome = "chess"


func saveDataOnSlot(slot:int):
	var saveData = {
		"player_health":player_health,
		"player_ammo": ammo,
		"player_max_ammo": ammoMax,
		"player_skin": currentPlayerSkin,
		"player_equiped_weapon_type":  currentEquipedWeaponType,
		"x_coord": player_x,
		"y_coord": player_y
	}
	var dir = "user://saves/"
	DirAccess.make_dir_recursive_absolute(dir)
	var file_path = dir + "save_%d.json" % slot
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(saveData))
		file.close()
		print("game was saved on slot " + str(slot))
	
	
	
