extends StaticBody2D

@onready var _treeSprite : Sprite2D = $Sprite2D
@onready var _animplayer : AnimationPlayer = $AnimationPlayer
@onready var _leafsLightOcludder : LightOccluder2D = $leafs
@onready var _rootLightOcludder : LightOccluder2D = $log
@onready var _fruitSpawnerMarker:Marker2D = $Sprite2D/fruitSpawnLocation
@export var fruitScene : PackedScene = preload("res://Scenes/objects/Fruit.tscn")
@export var rootTexture := preload("res://Assets/objects/tree_root.png")
@export var TreeParticles : PackedScene = preload("res://Scenes/particles/tree_explossion_particles.tscn")
@onready var _ParticleSpawnerMarker := $ParticleSpawnerMarker
var fruitCounter:= 0
var maxfruits := 2
var TurnedOn := false
var isTrimmed := false
var isBeingTrimmed := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animplayer.play("treemovement")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !isTrimmed:
		if TurnedOn and fruitCounter < maxfruits:
			TurnedOn = false
			if TurnedOn == false:
				fruitCounter += 1
				_spawn_fruit()
				
	if isBeingTrimmed and !isTrimmed:
		_spawnTreeParticles()
		isTrimmed = true
		_treeSprite.texture = rootTexture
	pass


func _spawnTreeParticles():
		var TreePart = TreeParticles.instantiate()
		_leafsLightOcludder.queue_free()
		_rootLightOcludder.queue_free()
		TreePart.global_position = _ParticleSpawnerMarker.global_position
		get_tree().current_scene.add_child(TreePart)



func _on_area_2d_body_entered(body: Node2D) -> void:
	if isTrimmed:
		return
	if body.is_in_group("PlayerArea"):
		if _leafsLightOcludder!=null:
			_leafsLightOcludder.visible = true
	else:
		return


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		if _leafsLightOcludder!=null:
			_leafsLightOcludder.visible = false
	return


func _spawn_fruit() -> void:
	if isTrimmed:
		return
	var new_fruit = fruitScene.instantiate()
	new_fruit.global_position = _fruitSpawnerMarker.global_position
	get_tree().current_scene.add_child(new_fruit)


func _on_shoot_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("SawArea"):
		isBeingTrimmed=true
	pass # Replace with function body.
