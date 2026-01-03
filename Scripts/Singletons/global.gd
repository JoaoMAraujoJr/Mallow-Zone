extends Node
var ammoMax : int = 0
var ammo : int = ammoMax
var kills : int = 0
var player_x: float = 0
var player_y: float = 0
var enemySpeed: float = 50.0
var player_health : int = 100

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
	if ammo > ammoMax :
		ammo = ammoMax
	pass


func UpdateBiome():
	if !BossManager._isOnBoss:
		if (player_x < 0.0 or player_x > -0.0 or player_y < 0.0 or player_y > -0.0):
			currentbiome = "grasslands"
		if (player_x > 10000.0 or player_x < -10000.0 or player_y > 10000.0 or player_y < -10000.0):
			currentbiome = "chess"
