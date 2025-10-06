extends Node
var ammoMax : int = 35
var ammo : int = ammoMax
var kills : int = 0
var player_x: float = 0
var player_y: float = 0
var enemySpeed: float = 50.0
var player_health : int = 100

var currentbiome : String = "chess"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ammo > ammoMax :
		ammo = ammoMax
	pass
