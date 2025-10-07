extends StaticBody2D

@onready var leafs : LightOccluder2D = $leafs
@onready var _animplayer : AnimationPlayer = $AnimationPlayer
@onready var _fruitSpawnerMarker:Marker2D = $Sprite2D/fruitSpawnLocation
@export var fruitScene : PackedScene = preload("res://Scenes/objects/Fruit.tscn")
var fruitCounter:= 0
var maxfruits := 2
var TurnedOn = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animplayer.play("treemovement")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if TurnedOn and fruitCounter < maxfruits:
		TurnedOn = false
		if TurnedOn == false:
			fruitCounter += 1
			_spawn_fruit()
	pass






func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		leafs.visible = true
	else:
		return


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		leafs.visible = false
	return


func _spawn_fruit() -> void:
	var new_fruit = fruitScene.instantiate()
	new_fruit.global_position = _fruitSpawnerMarker.global_position
	get_tree().current_scene.add_child(new_fruit)
